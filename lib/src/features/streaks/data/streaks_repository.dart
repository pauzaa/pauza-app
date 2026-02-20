import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/streaks/common/model/streak_constants.dart';
import 'package:pauza/src/features/streaks/common/model/streak_daily_aggregate.dart';
import 'package:pauza/src/features/streaks/common/model/streak_extensions.dart';
import 'package:pauza/src/features/streaks/common/model/streak_snapshot.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';
import 'package:pauza/src/features/streaks/data/streaks_rollup_math.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:sqflite/sqflite.dart';

part 'streaks_repository_rows.dart';

abstract interface class StreaksRepository {
  Future<void> refreshAggregates();

  Future<StreakSnapshot> getGlobalSnapshot({required DateTime nowLocal});
}

final class StreaksRepositoryImpl implements StreaksRepository {
  StreaksRepositoryImpl({
    required LocalDatabase localDatabase,
    DateTime Function()? nowUtc,
  }) : _localDatabase = localDatabase,
       _nowUtc = nowUtc ?? (() => DateTime.now().toUtc());

  static const int _refreshBatchSize = 500;

  final LocalDatabase _localDatabase;
  final DateTime Function() _nowUtc;

  Future<void>? _inFlightRefresh;

  @override
  Future<void> refreshAggregates() {
    final inFlight = _inFlightRefresh;
    if (inFlight != null) {
      return inFlight;
    }

    final refreshFuture = _refreshAggregatesInternal();
    _inFlightRefresh = refreshFuture;

    return refreshFuture.whenComplete(() {
      if (identical(_inFlightRefresh, refreshFuture)) {
        _inFlightRefresh = null;
      }
    });
  }

  Future<void> _refreshAggregatesInternal() async {
    try {
      while (true) {
        final processedCount = await _localDatabase.transaction((
          transaction,
        ) async {
          await _ensureStateRow(transaction: transaction);
          final state = await _readRollupState(transaction: transaction);

          final sessions = await _queryUpdatedSessions(
            transaction: transaction,
            cursorUpdatedAt: state.cursorUpdatedAt,
            cursorSessionId: state.cursorSessionId,
            limit: _refreshBatchSize,
          );

          final nowEpochMs = _nowUtc().millisecondsSinceEpoch;

          if (sessions.isEmpty) {
            await _updateLastRefreshAt(
              transaction: transaction,
              nowEpochMs: nowEpochMs,
            );
            return 0;
          }

          final affectedDays = <LocalDayKey>{};

          for (final session in sessions) {
            final oldDays = await _queryRollupDaysForSession(
              transaction: transaction,
              sessionId: session.sessionId,
            );
            affectedDays.addAll(oldDays);

            await _deleteRollupsForSession(
              transaction: transaction,
              sessionId: session.sessionId,
            );

            if (session.integrityStatus == 'anomaly') {
              continue;
            }

            final effectiveMsByDay = await _buildSessionEffectiveMsByDay(
              transaction: transaction,
              sessionId: session.sessionId,
              endedAtEpochMs: session.endedAtEpochMs,
              refreshNowUtc: DateTime.fromMillisecondsSinceEpoch(
                nowEpochMs,
                isUtc: true,
              ),
            );

            for (final dayEffectiveMs in effectiveMsByDay) {
              if (dayEffectiveMs.effectiveMs <= 0) {
                continue;
              }

              affectedDays.add(dayEffectiveMs.localDay);
              await _upsertSessionDayRollup(
                transaction: transaction,
                sessionId: session.sessionId,
                localDay: dayEffectiveMs.localDay,
                effectiveMs: dayEffectiveMs.effectiveMs,
                updatedAtEpochMs: nowEpochMs,
              );
            }
          }

          for (final dayKey in affectedDays) {
            await _recomputeDailyAggregate(
              transaction: transaction,
              localDay: dayKey,
              updatedAtEpochMs: nowEpochMs,
            );
          }

          final lastSession = sessions.last;
          await _updateRollupStateCursor(
            transaction: transaction,
            cursorUpdatedAt: lastSession.updatedAtEpochMs,
            cursorSessionId: lastSession.sessionId,
            lastRefreshAtEpochMs: nowEpochMs,
          );

          return sessions.length;
        });

        if (processedCount == 0) {
          return;
        }
      }
    } on Object {
      return;
    }
  }

  @override
  Future<StreakSnapshot> getGlobalSnapshot({required DateTime nowLocal}) async {
    await refreshAggregates();

    final asOfLocal = nowLocal.isUtc ? nowLocal.toLocal() : nowLocal;
    final todayKey = LocalDayKey.fromDateTime(asOfLocal);

    try {
      final rows = await _localDatabase.rawQuery(
        '''
SELECT
  local_day,
  effective_ms,
  qualified
FROM streak_daily_aggregates
WHERE local_day <= ?
ORDER BY local_day ASC
''',
        [todayKey.dbValue],
      );

      final dailyAggregates = rows.map(StreakDailyAggregate.fromJson).toIList();

      return StreakSnapshot.fromDailyAggregates(
        asOfLocal: asOfLocal,
        rows: dailyAggregates,
      );
    } on Object {
      return StreakSnapshot.zero(asOfLocal: asOfLocal);
    }
  }

  Future<void> _ensureStateRow({required Transaction transaction}) {
    return transaction.rawInsert('''
INSERT OR IGNORE INTO streak_rollup_state (
  id,
  session_cursor_updated_at,
  session_cursor_id,
  last_refresh_at
) VALUES (1, 0, '', 0)
''');
  }

  Future<_RollupStateRow> _readRollupState({
    required Transaction transaction,
  }) async {
    final rows = await transaction.rawQuery('''
SELECT
  session_cursor_updated_at,
  session_cursor_id
FROM streak_rollup_state
WHERE id = 1
LIMIT 1
''');

    return _RollupStateRow.fromJson(rows.first);
  }

  Future<IList<_SessionForRefresh>> _queryUpdatedSessions({
    required Transaction transaction,
    required int cursorUpdatedAt,
    required String cursorSessionId,
    required int limit,
  }) async {
    final rows = await transaction.rawQuery(
      '''
SELECT
  session_id,
  ended_at,
  integrity_status,
  updated_at
FROM restriction_sessions
WHERE updated_at > ? OR (updated_at = ? AND session_id > ?)
ORDER BY updated_at ASC, session_id ASC
LIMIT ?
''',
      [cursorUpdatedAt, cursorUpdatedAt, cursorSessionId, limit],
    );

    return rows.map(_SessionForRefresh.fromJson).toIList();
  }

  Future<Set<LocalDayKey>> _queryRollupDaysForSession({
    required Transaction transaction,
    required String sessionId,
  }) async {
    final rows = await transaction.rawQuery(
      'SELECT local_day FROM streak_session_daily_rollups WHERE session_id = ?',
      [sessionId],
    );

    return rows
        .map((row) => LocalDayKey.fromDb(row['local_day'] as String))
        .toSet();
  }

  Future<void> _deleteRollupsForSession({
    required Transaction transaction,
    required String sessionId,
  }) {
    return transaction.rawDelete(
      'DELETE FROM streak_session_daily_rollups WHERE session_id = ?',
      [sessionId],
    );
  }

  Future<List<_SessionDayEffectiveMsDto>> _buildSessionEffectiveMsByDay({
    required Transaction transaction,
    required String sessionId,
    required int? endedAtEpochMs,
    required DateTime refreshNowUtc,
  }) async {
    final rows = await transaction.rawQuery(
      '''
SELECT
  action,
  occurred_at,
  id
FROM restriction_lifecycle_events
WHERE session_id = ?
ORDER BY occurred_at ASC, id ASC
''',
      [sessionId],
    );

    final events = rows
        .map(_LifecycleEventPointDto.fromJson)
        .map((dto) => dto.toDomain())
        .toIList();

    final intervals = UtcInterval.buildEffectiveIntervals(
      events: events,
      endedAtUtc: endedAtEpochMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(endedAtEpochMs, isUtc: true),
      refreshNowUtc: refreshNowUtc,
    );

    return _SessionDayEffectiveMsDto.splitIntervalsByLocalDay(
      intervals: intervals,
    );
  }

  Future<void> _upsertSessionDayRollup({
    required Transaction transaction,
    required String sessionId,
    required LocalDayKey localDay,
    required int effectiveMs,
    required int updatedAtEpochMs,
  }) {
    return transaction.rawInsert(
      '''
INSERT INTO streak_session_daily_rollups (
  session_id,
  local_day,
  effective_ms,
  updated_at
) VALUES (?, ?, ?, ?)
ON CONFLICT(session_id, local_day) DO UPDATE SET
  effective_ms = excluded.effective_ms,
  updated_at = excluded.updated_at
''',
      [sessionId, localDay.dbValue, effectiveMs, updatedAtEpochMs],
    );
  }

  Future<void> _recomputeDailyAggregate({
    required Transaction transaction,
    required LocalDayKey localDay,
    required int updatedAtEpochMs,
  }) async {
    final rows = await transaction.rawQuery(
      '''
SELECT
  COALESCE(SUM(effective_ms), 0) AS total_effective_ms,
  COUNT(*) AS source_session_count
FROM streak_session_daily_rollups
WHERE local_day = ?
''',
      [localDay.dbValue],
    );

    final row = rows.first;
    final totalEffectiveMs = row['total_effective_ms'].intOrZero;
    final sourceSessionCount = row['source_session_count'].intOrZero;

    if (totalEffectiveMs <= 0) {
      await transaction.rawDelete(
        'DELETE FROM streak_daily_aggregates WHERE local_day = ?',
        [localDay.dbValue],
      );
      return;
    }

    await transaction.rawInsert(
      '''
INSERT INTO streak_daily_aggregates (
  local_day,
  effective_ms,
  qualified,
  source_session_count,
  updated_at
) VALUES (?, ?, ?, ?, ?)
ON CONFLICT(local_day) DO UPDATE SET
  effective_ms = excluded.effective_ms,
  qualified = excluded.qualified,
  source_session_count = excluded.source_session_count,
  updated_at = excluded.updated_at
''',
      [
        localDay.dbValue,
        totalEffectiveMs,
        totalEffectiveMs >= StreakConstants.targetDurationPerDay.inMilliseconds
            ? 1
            : 0,
        sourceSessionCount,
        updatedAtEpochMs,
      ],
    );
  }

  Future<void> _updateRollupStateCursor({
    required Transaction transaction,
    required int cursorUpdatedAt,
    required String cursorSessionId,
    required int lastRefreshAtEpochMs,
  }) {
    return transaction.rawUpdate(
      '''
UPDATE streak_rollup_state
SET
  session_cursor_updated_at = ?,
  session_cursor_id = ?,
  last_refresh_at = ?
WHERE id = 1
''',
      [cursorUpdatedAt, cursorSessionId, lastRefreshAtEpochMs],
    );
  }

  Future<void> _updateLastRefreshAt({
    required Transaction transaction,
    required int nowEpochMs,
  }) {
    return transaction.rawUpdate(
      'UPDATE streak_rollup_state SET last_refresh_at = ? WHERE id = 1',
      [nowEpochMs],
    );
  }
}
