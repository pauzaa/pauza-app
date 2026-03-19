import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/local_database/local_database_service.dart';
import 'package:pauza/src/features/streaks/common/model/streak_constants.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  group('StreaksRepositoryImpl', () {
    test('excludes anomalous sessions from rollups and qualification', () async {
      final database = _StubLocalDatabase();
      final nowUtc = DateTime.utc(2026, 1, 15, 12);
      final repository = StreaksRepositoryImpl(localDatabase: database, nowUtc: () => nowUtc);

      database.seedSession(
        sessionId: 's1',
        endedAtEpochMs: nowUtc.millisecondsSinceEpoch,
        integrityStatus: 'anomaly',
        updatedAtEpochMs: 100,
      );
      database.seedEvents(
        sessionId: 's1',
        events: [
          _event(action: 'START', occurredAtUtc: nowUtc.subtract(const Duration(minutes: 30))),
          _event(action: 'END', occurredAtUtc: nowUtc),
        ],
      );

      await repository.refreshAggregates();

      expect(database.streakSessionDailyRollups, isEmpty);
      expect(database.streakDailyAggregates, isEmpty);
    });

    test('incremental refresh no-op on unchanged cursor and reprocess on updated session', () async {
      final database = _StubLocalDatabase();
      final nowUtc = DateTime.utc(2026, 1, 15, 12);
      final repository = StreaksRepositoryImpl(localDatabase: database, nowUtc: () => nowUtc);

      database.seedSession(sessionId: 's1', endedAtEpochMs: 2_000, integrityStatus: 'ok', updatedAtEpochMs: 100);
      database.seedEvents(
        sessionId: 's1',
        events: [
          _event(action: 'START', occurredAtUtc: _utc(1_000)),
          _event(action: 'END', occurredAtUtc: _utc(2_000)),
        ],
      );

      await repository.refreshAggregates();
      final firstRollupUpserts = database.rollupUpsertCount;
      final firstAggregateUpserts = database.aggregateUpsertCount;

      await repository.refreshAggregates();
      expect(database.rollupUpsertCount, firstRollupUpserts);
      expect(database.aggregateUpsertCount, firstAggregateUpserts);

      database.seedSession(sessionId: 's1', endedAtEpochMs: 3_000, integrityStatus: 'ok', updatedAtEpochMs: 200);
      database.seedEvents(
        sessionId: 's1',
        events: [
          _event(action: 'START', occurredAtUtc: _utc(1_000)),
          _event(action: 'END', occurredAtUtc: _utc(3_000)),
        ],
      );

      await repository.refreshAggregates();

      expect(database.rollupUpsertCount, greaterThan(firstRollupUpserts));
      expect(database.aggregateUpsertCount, greaterThan(firstAggregateUpserts));
      final row = database.streakSessionDailyRollups.values.single;
      expect(row.effectiveMs, 2_000);
    });

    test('dedupes in-flight refreshes', () async {
      final database = _StubLocalDatabase()..restrictionSessionsQueryDelay = const Duration(milliseconds: 30);
      final nowUtc = DateTime.utc(2026, 1, 15, 12);
      final repository = StreaksRepositoryImpl(localDatabase: database, nowUtc: () => nowUtc);

      database.seedSession(sessionId: 's1', endedAtEpochMs: 2_000, integrityStatus: 'ok', updatedAtEpochMs: 100);
      database.seedEvents(
        sessionId: 's1',
        events: [
          _event(action: 'START', occurredAtUtc: _utc(1_000)),
          _event(action: 'END', occurredAtUtc: _utc(2_000)),
        ],
      );

      await Future.wait([repository.refreshAggregates(), repository.refreshAggregates()]);

      expect(database.restrictionSessionsQueryCount, 2);
    });

    test('getGlobalSnapshot includes in-progress contribution for today', () async {
      final nowUtc = DateTime.utc(2026, 1, 15, 12);
      final nowLocal = nowUtc.toLocal();
      final database = _StubLocalDatabase();
      final repository = StreaksRepositoryImpl(localDatabase: database, nowUtc: () => nowUtc);

      database.seedSession(sessionId: 's1', endedAtEpochMs: null, integrityStatus: 'ok', updatedAtEpochMs: 100);
      database.seedEvents(
        sessionId: 's1',
        events: [_event(action: 'START', occurredAtUtc: nowUtc.subtract(const Duration(minutes: 35)))],
      );

      final snapshot = await repository.getGlobalSnapshot(nowLocal: nowLocal);

      expect(snapshot.todayEffectiveDuration, const Duration(minutes: 35));
      expect(snapshot.todayQualified, isTrue);
      expect(snapshot.currentStreakDays, 1);
      expect(snapshot.bestStreakDays, 1);
      expect(snapshot.targetDurationPerDay, StreakConstants.targetDurationPerDay);
    });

    test('25-min session is NOT qualified under 30-min threshold', () async {
      final database = _StubLocalDatabase();
      final nowUtc = DateTime.utc(2026, 1, 15, 12);
      final repository = StreaksRepositoryImpl(localDatabase: database, nowUtc: () => nowUtc);

      database.seedSession(
        sessionId: 's1',
        endedAtEpochMs: nowUtc.millisecondsSinceEpoch,
        integrityStatus: 'ok',
        updatedAtEpochMs: 100,
      );
      database.seedEvents(
        sessionId: 's1',
        events: [
          _event(action: 'START', occurredAtUtc: nowUtc.subtract(const Duration(minutes: 25))),
          _event(action: 'END', occurredAtUtc: nowUtc),
        ],
      );

      await repository.refreshAggregates();

      final aggregate = database.streakDailyAggregates.values.single;
      expect(aggregate.qualified, isFalse);
    });

    test('30-min session IS qualified under 30-min threshold', () async {
      final database = _StubLocalDatabase();
      final nowUtc = DateTime.utc(2026, 1, 15, 12);
      final repository = StreaksRepositoryImpl(localDatabase: database, nowUtc: () => nowUtc);

      database.seedSession(
        sessionId: 's1',
        endedAtEpochMs: nowUtc.millisecondsSinceEpoch,
        integrityStatus: 'ok',
        updatedAtEpochMs: 100,
      );
      database.seedEvents(
        sessionId: 's1',
        events: [
          _event(action: 'START', occurredAtUtc: nowUtc.subtract(const Duration(minutes: 30))),
          _event(action: 'END', occurredAtUtc: nowUtc),
        ],
      );

      await repository.refreshAggregates();

      final aggregate = database.streakDailyAggregates.values.single;
      expect(aggregate.qualified, isTrue);
    });

    test('computes best streak from aggregates', () async {
      final nowLocal = DateTime(2026, 1, 15, 9);
      final database = _StubLocalDatabase();
      final repository = StreaksRepositoryImpl(localDatabase: database, nowUtc: () => nowLocal.toUtc());

      database.seedDailyAggregate(
        localDay: '2026-01-08',
        effectiveMs: StreakConstants.targetDurationPerDay.inMilliseconds,
        qualified: true,
      );
      database.seedDailyAggregate(
        localDay: '2026-01-09',
        effectiveMs: StreakConstants.targetDurationPerDay.inMilliseconds,
        qualified: true,
      );
      database.seedDailyAggregate(
        localDay: '2026-01-10',
        effectiveMs: StreakConstants.targetDurationPerDay.inMilliseconds,
        qualified: true,
      );
      database.seedDailyAggregate(
        localDay: '2026-01-12',
        effectiveMs: StreakConstants.targetDurationPerDay.inMilliseconds,
        qualified: true,
      );
      database.seedDailyAggregate(
        localDay: '2026-01-13',
        effectiveMs: StreakConstants.targetDurationPerDay.inMilliseconds,
        qualified: true,
      );

      final snapshot = await repository.getGlobalSnapshot(nowLocal: nowLocal);

      expect(snapshot.currentStreakDays, 0);
      expect(snapshot.bestStreakDays, 3);
    });
  });
}

_DateTimeEvent _event({required String action, required DateTime occurredAtUtc}) {
  return _DateTimeEvent(action: action, occurredAtUtc: occurredAtUtc);
}

DateTime _utc(int epochMs) {
  return DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true);
}

final class _DateTimeEvent {
  const _DateTimeEvent({required this.action, required this.occurredAtUtc});

  final String action;
  final DateTime occurredAtUtc;
}

final class _StreakRollupRow {
  const _StreakRollupRow({
    required this.sessionId,
    required this.localDay,
    required this.effectiveMs,
    required this.updatedAt,
  });

  final String sessionId;
  final String localDay;
  final int effectiveMs;
  final int updatedAt;
}

final class _StreakDailyAggregateRow {
  const _StreakDailyAggregateRow({
    required this.localDay,
    required this.effectiveMs,
    required this.qualified,
    required this.sourceSessionCount,
    required this.updatedAt,
  });

  final String localDay;
  final int effectiveMs;
  final bool qualified;
  final int sourceSessionCount;
  final int updatedAt;
}

final class _RestrictionSessionRow {
  const _RestrictionSessionRow({
    required this.sessionId,
    required this.endedAtEpochMs,
    required this.integrityStatus,
    required this.updatedAtEpochMs,
  });

  final String sessionId;
  final int? endedAtEpochMs;
  final String integrityStatus;
  final int updatedAtEpochMs;
}

final class _StubLocalDatabase implements LocalDatabase {
  final Map<String, _RestrictionSessionRow> restrictionSessions = <String, _RestrictionSessionRow>{};
  final Map<String, List<_DateTimeEvent>> restrictionEvents = <String, List<_DateTimeEvent>>{};
  final Map<String, _StreakRollupRow> streakSessionDailyRollups = <String, _StreakRollupRow>{};
  final Map<String, _StreakDailyAggregateRow> streakDailyAggregates = <String, _StreakDailyAggregateRow>{};
  Map<String, Object?>? streakRollupState;

  int rollupUpsertCount = 0;
  int aggregateUpsertCount = 0;
  int restrictionSessionsQueryCount = 0;
  Duration restrictionSessionsQueryDelay = Duration.zero;

  void seedSession({
    required String sessionId,
    required int? endedAtEpochMs,
    required String integrityStatus,
    required int updatedAtEpochMs,
  }) {
    restrictionSessions[sessionId] = _RestrictionSessionRow(
      sessionId: sessionId,
      endedAtEpochMs: endedAtEpochMs,
      integrityStatus: integrityStatus,
      updatedAtEpochMs: updatedAtEpochMs,
    );
  }

  void seedEvents({required String sessionId, required List<_DateTimeEvent> events}) {
    restrictionEvents[sessionId] = events;
  }

  void seedDailyAggregate({required String localDay, required int effectiveMs, required bool qualified}) {
    streakDailyAggregates[localDay] = _StreakDailyAggregateRow(
      localDay: localDay,
      effectiveMs: effectiveMs,
      qualified: qualified,
      sourceSessionCount: 1,
      updatedAt: 0,
    );
  }

  @override
  bool get isOpen => true;

  @override
  Future<void> close() async {}

  @override
  Future<void> open() async {}

  @override
  Future<T> read<T>(Future<T> Function(DatabaseExecutor database) action) async {
    throw UnsupportedError('Not used in tests.');
  }

  @override
  Future<T> write<T>(Future<T> Function(DatabaseExecutor database) action) async {
    throw UnsupportedError('Not used in tests.');
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction transaction) action) async {
    final transaction = _StubTransaction(fakeDatabase: this);
    return action(transaction);
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (sql.contains('FROM streak_daily_aggregates')) {
      final maxDay = arguments?.first as String;
      final rows =
          streakDailyAggregates.values
              .where((row) => row.localDay.compareTo(maxDay) <= 0)
              .map(
                (row) => <String, Object?>{
                  'local_day': row.localDay,
                  'effective_ms': row.effectiveMs,
                  'qualified': row.qualified ? 1 : 0,
                },
              )
              .toList(growable: false)
            ..sort((a, b) => (a['local_day'] as String).compareTo(b['local_day'] as String));
      return rows;
    }

    throw UnsupportedError('Unsupported rawQuery: $sql');
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    throw UnsupportedError('Not used in tests.');
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    throw UnsupportedError('Not used in tests.');
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    throw UnsupportedError('Not used in tests.');
  }
}

final class _StubTransaction implements Transaction {
  _StubTransaction({required _StubLocalDatabase fakeDatabase}) : _fakeDatabase = fakeDatabase;

  final _StubLocalDatabase _fakeDatabase;

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (sql.contains('FROM streak_rollup_state')) {
      final row = _fakeDatabase.streakRollupState;
      if (row == null) {
        return const <Map<String, Object?>>[];
      }
      return <Map<String, Object?>>[row];
    }

    if (sql.contains('FROM restriction_sessions')) {
      _fakeDatabase.restrictionSessionsQueryCount += 1;
      if (_fakeDatabase.restrictionSessionsQueryDelay > Duration.zero) {
        await Future<void>.delayed(_fakeDatabase.restrictionSessionsQueryDelay);
      }

      final cursorUpdatedAt = arguments![0] as int;
      final cursorSessionId = arguments[2] as String;
      final limit = arguments[3] as int;

      final rows =
          _fakeDatabase.restrictionSessions.values
              .where(
                (row) =>
                    row.updatedAtEpochMs > cursorUpdatedAt ||
                    (row.updatedAtEpochMs == cursorUpdatedAt && row.sessionId.compareTo(cursorSessionId) > 0),
              )
              .toList(growable: false)
            ..sort((a, b) {
              final byUpdated = a.updatedAtEpochMs.compareTo(b.updatedAtEpochMs);
              if (byUpdated != 0) {
                return byUpdated;
              }
              return a.sessionId.compareTo(b.sessionId);
            });

      return rows
          .take(limit)
          .map((row) {
            return <String, Object?>{
              'session_id': row.sessionId,
              'ended_at': row.endedAtEpochMs,
              'integrity_status': row.integrityStatus,
              'updated_at': row.updatedAtEpochMs,
            };
          })
          .toList(growable: false);
    }

    if (sql.contains('FROM streak_session_daily_rollups WHERE session_id = ?')) {
      final sessionId = arguments!.first as String;
      return _fakeDatabase.streakSessionDailyRollups.values
          .where((row) => row.sessionId == sessionId)
          .map((row) => <String, Object?>{'local_day': row.localDay})
          .toList(growable: false);
    }

    if (sql.contains('FROM restriction_lifecycle_events')) {
      final sessionId = arguments!.first as String;
      final events = _fakeDatabase.restrictionEvents[sessionId] ?? const <_DateTimeEvent>[];
      final sorted = events.toList(growable: false)..sort((a, b) => a.occurredAtUtc.compareTo(b.occurredAtUtc));

      var index = 0;
      return sorted
          .map((event) {
            index += 1;
            return <String, Object?>{
              'action': event.action,
              'occurred_at': event.occurredAtUtc.millisecondsSinceEpoch,
              'id': '$sessionId-$index',
            };
          })
          .toList(growable: false);
    }

    if (sql.contains('FROM streak_session_daily_rollups') && sql.contains('COALESCE(SUM(effective_ms), 0)')) {
      final localDay = arguments!.first as String;
      final dayRows = _fakeDatabase.streakSessionDailyRollups.values.where((row) => row.localDay == localDay);
      final total = dayRows.fold<int>(0, (sum, row) => sum + row.effectiveMs);
      final count = dayRows.length;
      return <Map<String, Object?>>[
        <String, Object?>{'total_effective_ms': total, 'source_session_count': count},
      ];
    }

    throw UnsupportedError('Unsupported rawQuery: $sql');
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    final args = arguments ?? const <Object?>[];

    if (sql.contains('INSERT OR IGNORE INTO streak_rollup_state')) {
      _fakeDatabase.streakRollupState ??= <String, Object?>{
        'session_cursor_updated_at': 0,
        'session_cursor_id': '',
        'last_refresh_at': 0,
      };
      return 1;
    }

    if (sql.contains('INSERT INTO streak_session_daily_rollups')) {
      _fakeDatabase.rollupUpsertCount += 1;
      final sessionId = args[0] as String;
      final localDay = args[1] as String;
      final key = '$sessionId|$localDay';
      _fakeDatabase.streakSessionDailyRollups[key] = _StreakRollupRow(
        sessionId: sessionId,
        localDay: localDay,
        effectiveMs: args[2] as int,
        updatedAt: args[3] as int,
      );
      return 1;
    }

    if (sql.contains('INSERT INTO streak_daily_aggregates')) {
      _fakeDatabase.aggregateUpsertCount += 1;
      final localDay = args[0] as String;
      _fakeDatabase.streakDailyAggregates[localDay] = _StreakDailyAggregateRow(
        localDay: localDay,
        effectiveMs: args[1] as int,
        qualified: (args[2] as int) == 1,
        sourceSessionCount: args[3] as int,
        updatedAt: args[4] as int,
      );
      return 1;
    }

    throw UnsupportedError('Unsupported rawInsert: $sql');
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    final args = arguments ?? const <Object?>[];

    if (sql.contains('UPDATE streak_rollup_state') && sql.contains('session_cursor_updated_at')) {
      _fakeDatabase.streakRollupState = <String, Object?>{
        'session_cursor_updated_at': args[0] as int,
        'session_cursor_id': args[1] as String,
        'last_refresh_at': args[2] as int,
      };
      return 1;
    }

    if (sql.contains('UPDATE streak_rollup_state SET last_refresh_at')) {
      final current =
          _fakeDatabase.streakRollupState ??
          <String, Object?>{'session_cursor_updated_at': 0, 'session_cursor_id': '', 'last_refresh_at': 0};
      current['last_refresh_at'] = args[0] as int;
      _fakeDatabase.streakRollupState = current;
      return 1;
    }

    throw UnsupportedError('Unsupported rawUpdate: $sql');
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    final args = arguments ?? const <Object?>[];

    if (sql.contains('DELETE FROM streak_session_daily_rollups WHERE session_id = ?')) {
      final sessionId = args[0] as String;
      final keysToRemove = _fakeDatabase.streakSessionDailyRollups.entries
          .where((entry) => entry.value.sessionId == sessionId)
          .map((entry) => entry.key)
          .toList(growable: false);
      for (final key in keysToRemove) {
        _fakeDatabase.streakSessionDailyRollups.remove(key);
      }
      return keysToRemove.length;
    }

    if (sql.contains('DELETE FROM streak_daily_aggregates WHERE local_day = ?')) {
      final localDay = args[0] as String;
      return _fakeDatabase.streakDailyAggregates.remove(localDay) == null ? 0 : 1;
    }

    throw UnsupportedError('Unsupported rawDelete: $sql');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
