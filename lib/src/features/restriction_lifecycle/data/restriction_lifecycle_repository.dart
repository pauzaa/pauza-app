import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_lifecycle_event_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_session_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_plugin_client.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_session_reducer.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class RestrictionLifecycleRepository {
  Future<void> syncFromPluginQueue({int batchSize = 200});

  Future<List<RestrictionSessionLog>> getSessions({String? modeId, int limit = 200});

  Future<List<RestrictionLifecycleEventLog>> getEvents({String? modeId, String? sessionId, int limit = 500});
}

final class RestrictionLifecycleRepositoryImpl implements RestrictionLifecycleRepository {
  RestrictionLifecycleRepositoryImpl({required LocalDatabase localDatabase, required RestrictionLifecyclePluginClient pluginClient})
    : _localDatabase = localDatabase,
      _pluginClient = pluginClient,
      _reducer = const RestrictionSessionReducer();

  final LocalDatabase _localDatabase;
  final RestrictionLifecyclePluginClient _pluginClient;
  final RestrictionSessionReducer _reducer;

  @override
  Future<void> syncFromPluginQueue({int batchSize = 200}) async {
    if (batchSize <= 0) {
      throw ArgumentError.value(batchSize, 'batchSize', 'batchSize must be > 0');
    }

    while (true) {
      final events = await _pluginClient.getPendingLifecycleEvents(limit: batchSize);
      if (events.isEmpty) {
        return;
      }

      await _localDatabase.transaction((transaction) async {
        for (final event in events) {
          final inserted = await _insertEventIgnore(transaction: transaction, event: event);
          if (!inserted) {
            continue;
          }

          final currentSession = await _getSessionById(transaction: transaction, sessionId: event.sessionId);

          final session = _reducer.reduce(event: event, currentSession: currentSession, nowUtc: DateTime.now().toUtc());

          await _upsertSession(transaction: transaction, session: session);
        }
      });

      await _pluginClient.ackLifecycleEvents(throughEventId: events.last.id);
    }
  }

  @override
  Future<List<RestrictionSessionLog>> getSessions({String? modeId, int limit = 200}) async {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'limit must be > 0');
    }

    final arguments = <Object?>[];
    var whereClause = '';

    if (modeId case final selectedModeId?) {
      whereClause = 'WHERE mode_id = ?';
      arguments.add(selectedModeId);
    }

    arguments.add(limit);

    final rows = await _localDatabase.rawQuery('''
SELECT
  session_id,
  mode_id,
  source,
  started_at,
  ended_at,
  pause_count,
  total_paused_ms,
  last_paused_at,
  integrity_status,
  last_anomaly_reason,
  last_event_id,
  created_at,
  updated_at
FROM restriction_sessions
$whereClause
ORDER BY started_at DESC
LIMIT ?
''', arguments);

    return rows.map(RestrictionSessionLog.fromDbRow).toList(growable: false);
  }

  @override
  Future<List<RestrictionLifecycleEventLog>> getEvents({String? modeId, String? sessionId, int limit = 500}) async {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'limit must be > 0');
    }

    final arguments = <Object?>[];
    final whereClauses = <String>[];

    if (modeId case final selectedModeId?) {
      whereClauses.add('mode_id = ?');
      arguments.add(selectedModeId);
    }

    if (sessionId case final selectedSessionId?) {
      whereClauses.add('session_id = ?');
      arguments.add(selectedSessionId);
    }

    final whereClause = whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}';

    arguments.add(limit);

    final rows = await _localDatabase.rawQuery('''
SELECT
  id,
  session_id,
  mode_id,
  action,
  source,
  reason,
  occurred_at,
  created_at
FROM restriction_lifecycle_events
$whereClause
ORDER BY occurred_at DESC
LIMIT ?
''', arguments);

    return rows.map(RestrictionLifecycleEventLog.fromDbRow).toList(growable: false);
  }

  Future<bool> _insertEventIgnore({required Transaction transaction, required RestrictionLifecycleEvent event}) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    final insertedRowId = await transaction.rawInsert(
      '''
INSERT OR IGNORE INTO restriction_lifecycle_events (
  id,
  session_id,
  mode_id,
  action,
  source,
  reason,
  occurred_at,
  created_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
      [
        event.id,
        event.sessionId,
        event.modeId,
        event.action.wireValue,
        event.source.wireValue,
        event.reason,
        event.occurredAt.toUtc().millisecondsSinceEpoch,
        now,
      ],
    );

    return insertedRowId != 0;
  }

  Future<RestrictionSessionLog?> _getSessionById({required Transaction transaction, required String sessionId}) async {
    final rows = await transaction.rawQuery(
      '''
SELECT
  session_id,
  mode_id,
  source,
  started_at,
  ended_at,
  pause_count,
  total_paused_ms,
  last_paused_at,
  integrity_status,
  last_anomaly_reason,
  last_event_id,
  created_at,
  updated_at
FROM restriction_sessions
WHERE session_id = ?
LIMIT 1
''',
      [sessionId],
    );

    if (rows.isEmpty) {
      return null;
    }

    return RestrictionSessionLog.fromDbRow(rows.first);
  }

  Future<void> _upsertSession({required Transaction transaction, required RestrictionSessionLog session}) async {
    await transaction.rawInsert('''
INSERT INTO restriction_sessions (
  session_id,
  mode_id,
  source,
  started_at,
  ended_at,
  pause_count,
  total_paused_ms,
  last_paused_at,
  integrity_status,
  last_anomaly_reason,
  last_event_id,
  created_at,
  updated_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(session_id) DO UPDATE SET
  mode_id = excluded.mode_id,
  source = excluded.source,
  started_at = excluded.started_at,
  ended_at = excluded.ended_at,
  pause_count = excluded.pause_count,
  total_paused_ms = excluded.total_paused_ms,
  last_paused_at = excluded.last_paused_at,
  integrity_status = excluded.integrity_status,
  last_anomaly_reason = excluded.last_anomaly_reason,
  last_event_id = excluded.last_event_id,
  created_at = excluded.created_at,
  updated_at = excluded.updated_at
''', session.toUpsertArgs());
  }
}
