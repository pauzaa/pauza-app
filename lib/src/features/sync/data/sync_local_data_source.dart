import 'dart:convert';

import 'package:pauza/src/core/local_database/local_database_service.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_lifecycle_event_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_session_log.dart';
import 'package:pauza/src/features/sync/common/model/rows/sync_mode_rows.dart';
import 'package:pauza/src/features/sync/common/model/rows/sync_streak_rows.dart';
import 'package:pauza/src/features/sync/common/model/sync_request_dto.dart';
import 'package:pauza/src/features/sync/common/model/sync_response_dto.dart';
import 'package:pauza/src/features/sync/common/model/sync_table.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class SyncLocalDataSource {
  Future<bool> hasAnySyncCursor();
  Future<SyncRequestDto> buildSyncRequest();
  Future<void> applySyncResponse(SyncResponseDto response);
  Future<void> trackDeletion({required SyncTable table, required Object key});
  Future<void> clearAllSyncableTables();
}

final class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  const SyncLocalDataSourceImpl({required LocalDatabase database})
      : _database = database;

  final LocalDatabase _database;

  // ---------------------------------------------------------------------------
  // hasAnySyncCursor
  // ---------------------------------------------------------------------------

  @override
  Future<bool> hasAnySyncCursor() async {
    final rows = await _database.rawQuery(
      'SELECT 1 FROM sync_cursors LIMIT 1',
    );
    return rows.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // buildSyncRequest
  // ---------------------------------------------------------------------------

  @override
  Future<SyncRequestDto> buildSyncRequest() async {
    final tables = <String, SyncTableRequestDto>{};

    for (final table in SyncTable.values) {
      final cursor = await _readCursor(table);
      if (table.readOnly) {
        tables[table.key] = SyncTableRequestDto(cursor: cursor);
      } else {
        final upserts = await _readUnsyncedRows(table, cursor);
        final deletions = await _readTrackedDeletions(table);
        tables[table.key] = SyncTableRequestDto(
          cursor: cursor,
          upserts: upserts,
          deletions: deletions,
        );
      }
    }

    return SyncRequestDto(tables: tables);
  }

  Future<int> _readCursor(SyncTable table) async {
    final rows = await _database.rawQuery(
      'SELECT last_synced_at FROM sync_cursors WHERE table_name = ?',
      [table.key],
    );
    if (rows.isEmpty) return 0;
    return rows.first['last_synced_at'] as int;
  }

  Future<List<Map<String, Object?>>> _readUnsyncedRows(
    SyncTable table,
    int cursor,
  ) async {
    final rows = await _database.rawQuery(
      'SELECT * FROM ${table.key} WHERE ${table.cursorColumn} > ?',
      [cursor],
    );
    return rows.map((row) => _parseAndSerialize(table, row)).toList();
  }

  Map<String, Object?> _parseAndSerialize(
    SyncTable table,
    Map<String, Object?> row,
  ) {
    return switch (table) {
      SyncTable.modes => SyncModeRow.fromMap(row).toMap(),
      SyncTable.modeBlockedApps => SyncModeBlockedAppRow.fromMap(row).toMap(),
      SyncTable.schedules => SyncScheduleRow.fromMap(row).toMap(),
      SyncTable.restrictionSessions =>
        RestrictionSessionLog.fromDbRow(row).toMap(),
      SyncTable.restrictionLifecycleEvents =>
        RestrictionLifecycleEventLog.fromDbRow(row).toMap(),
      SyncTable.nfcLinkedChips => NfcLinkedChip.fromDbRow(row).toMap(),
      SyncTable.qrLinkedCodes => QrLinkedCode.fromDbRow(row).toMap(),
      SyncTable.streakSessionDailyRollups =>
        SyncStreakRollupRow.fromMap(row).toMap(),
      SyncTable.streakDailyAggregates =>
        SyncStreakAggregateRow.fromMap(row).toMap(),
    };
  }

  Future<List<Object>> _readTrackedDeletions(SyncTable table) async {
    final rows = await _database.rawQuery(
      'SELECT deletion_key FROM sync_deletion_log WHERE table_name = ?',
      [table.key],
    );
    return rows.map((row) {
      final raw = row['deletion_key'] as String;
      return _decodeDeletionKey(table, raw);
    }).toList();
  }

  Object _decodeDeletionKey(SyncTable table, String raw) {
    return switch (table) {
      SyncTable.modeBlockedApps ||
      SyncTable.streakSessionDailyRollups =>
        jsonDecode(raw) as Map<String, Object?>,
      _ => raw,
    };
  }

  // ---------------------------------------------------------------------------
  // applySyncResponse
  // ---------------------------------------------------------------------------

  @override
  Future<void> applySyncResponse(SyncResponseDto response) async {
    await _database.transaction((txn) async {
      for (final table in SyncTable.values) {
        final tableData = response.tables[table.key];
        if (tableData == null) continue;

        for (final row in tableData.upserts) {
          final parsed = _parseAndSerialize(table, row);
          await _upsertRow(txn, table, parsed);
        }

        for (final key in tableData.deletions) {
          await _deleteRow(txn, table, key);
        }

        await txn.rawInsert(
          'INSERT OR REPLACE INTO sync_cursors (table_name, last_synced_at) '
          'VALUES (?, ?)',
          [table.key, tableData.nextCursor],
        );

        await txn.rawDelete(
          'DELETE FROM sync_deletion_log WHERE table_name = ?',
          [table.key],
        );
      }
    });
  }

  Future<void> _upsertRow(
    Transaction txn,
    SyncTable table,
    Map<String, Object?> row,
  ) async {
    final sql = _upsertSql[table]!;
    final args = _upsertArgs(table, row);
    await txn.rawInsert(sql, args);
  }

  List<Object?> _upsertArgs(SyncTable table, Map<String, Object?> row) {
    return switch (table) {
      SyncTable.modes => [
          row['id'],
          row['title'],
          row['text_on_screen'],
          row['description'],
          row['allowed_pauses_count'],
          row['minimum_duration_ms'],
          row['ending_pausing_scenario'],
          row['icon_token'],
          row['created_at'],
          row['updated_at'],
        ],
      SyncTable.modeBlockedApps => [
          row['mode_id'],
          row['platform'],
          row['app_identifier'],
          row['created_at'],
          row['updated_at'],
        ],
      SyncTable.schedules => [
          row['id'],
          row['mode_id'],
          row['days'],
          row['start_minute'],
          row['end_minute'],
          row['enabled'],
          row['created_at'],
          row['updated_at'],
        ],
      SyncTable.restrictionSessions => [
          row['session_id'],
          row['mode_id'],
          row['source'],
          row['started_at'],
          row['ended_at'],
          row['pause_count'],
          row['total_paused_ms'],
          row['last_paused_at'],
          row['integrity_status'],
          row['last_anomaly_reason'],
          row['last_event_id'],
          row['created_at'],
          row['updated_at'],
        ],
      SyncTable.restrictionLifecycleEvents => [
          row['id'],
          row['session_id'],
          row['mode_id'],
          row['action'],
          row['source'],
          row['reason'],
          row['occurred_at'],
          row['created_at'],
        ],
      SyncTable.nfcLinkedChips => [
          row['id'],
          row['chip_identifier'],
          row['name'],
          row['created_at'],
          row['updated_at'],
        ],
      SyncTable.qrLinkedCodes => [
          row['id'],
          row['scan_value'],
          row['name'],
          row['created_at'],
          row['updated_at'],
        ],
      SyncTable.streakSessionDailyRollups => [
          row['session_id'],
          row['local_day'],
          row['effective_ms'],
          row['updated_at'],
        ],
      SyncTable.streakDailyAggregates => [
          row['local_day'],
          row['effective_ms'],
          row['qualified'],
          row['source_session_count'],
          row['updated_at'],
        ],
    };
  }

  Future<void> _deleteRow(
    Transaction txn,
    SyncTable table,
    Object key,
  ) async {
    switch (table) {
      case SyncTable.modeBlockedApps:
        final compositeKey = key as Map<String, Object?>;
        await txn.rawDelete(
          'DELETE FROM mode_blocked_apps '
          'WHERE mode_id = ? AND platform = ? AND app_identifier = ?',
          [
            compositeKey['mode_id'],
            compositeKey['platform'],
            compositeKey['app_identifier'],
          ],
        );
      case SyncTable.streakSessionDailyRollups:
        final compositeKey = key as Map<String, Object?>;
        await txn.rawDelete(
          'DELETE FROM streak_session_daily_rollups '
          'WHERE session_id = ? AND local_day = ?',
          [compositeKey['session_id'], compositeKey['local_day']],
        );
      case SyncTable.modes:
        await txn.rawDelete('DELETE FROM modes WHERE id = ?', [key]);
      case SyncTable.schedules:
        await txn.rawDelete('DELETE FROM schedules WHERE id = ?', [key]);
      case SyncTable.restrictionSessions:
        await txn.rawDelete(
          'DELETE FROM restriction_sessions WHERE session_id = ?',
          [key],
        );
      case SyncTable.restrictionLifecycleEvents:
        await txn.rawDelete(
          'DELETE FROM restriction_lifecycle_events WHERE id = ?',
          [key],
        );
      case SyncTable.nfcLinkedChips:
        await txn.rawDelete(
          'DELETE FROM nfc_linked_chips WHERE id = ?',
          [key],
        );
      case SyncTable.qrLinkedCodes:
        await txn.rawDelete(
          'DELETE FROM qr_linked_codes WHERE id = ?',
          [key],
        );
      case SyncTable.streakDailyAggregates:
        await txn.rawDelete(
          'DELETE FROM streak_daily_aggregates WHERE local_day = ?',
          [key],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // trackDeletion
  // ---------------------------------------------------------------------------

  @override
  Future<void> trackDeletion({
    required SyncTable table,
    required Object key,
  }) async {
    final encoded = switch (key) {
      final Map<String, Object?> composite => jsonEncode(composite),
      _ => key as String,
    };

    await _database.rawInsert(
      'INSERT OR REPLACE INTO sync_deletion_log '
      '(table_name, deletion_key, deleted_at) VALUES (?, ?, ?)',
      [table.key, encoded, DateTime.now().toUtc().millisecondsSinceEpoch],
    );
  }

  // ---------------------------------------------------------------------------
  // clearAllSyncableTables
  // ---------------------------------------------------------------------------

  @override
  Future<void> clearAllSyncableTables() async {
    await _database.transaction((txn) async {
      // FK children first
      await txn.rawDelete('DELETE FROM mode_blocked_apps');
      await txn.rawDelete('DELETE FROM schedules');
      await txn.rawDelete('DELETE FROM streak_session_daily_rollups');
      // FK parents and independent tables
      await txn.rawDelete('DELETE FROM modes');
      await txn.rawDelete('DELETE FROM restriction_sessions');
      await txn.rawDelete('DELETE FROM restriction_lifecycle_events');
      await txn.rawDelete('DELETE FROM nfc_linked_chips');
      await txn.rawDelete('DELETE FROM qr_linked_codes');
      await txn.rawDelete('DELETE FROM streak_daily_aggregates');
      // Sync metadata
      await txn.rawDelete('DELETE FROM sync_cursors');
      await txn.rawDelete('DELETE FROM sync_deletion_log');
      // Reset local-only singleton to defaults
      await txn.rawUpdate(
        'UPDATE streak_rollup_state SET '
        'session_cursor_updated_at = 0, '
        "session_cursor_id = '', "
        'last_refresh_at = 0 '
        'WHERE id = 1',
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Per-table upsert SQL
  // ---------------------------------------------------------------------------

  static const _upsertSql = <SyncTable, String>{
    SyncTable.modes: '''
INSERT INTO modes (id, title, text_on_screen, description, allowed_pauses_count,
  minimum_duration_ms, ending_pausing_scenario, icon_token, created_at, updated_at)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  title = excluded.title,
  text_on_screen = excluded.text_on_screen,
  description = excluded.description,
  allowed_pauses_count = excluded.allowed_pauses_count,
  minimum_duration_ms = excluded.minimum_duration_ms,
  ending_pausing_scenario = excluded.ending_pausing_scenario,
  icon_token = excluded.icon_token,
  created_at = excluded.created_at,
  updated_at = excluded.updated_at
''',
    SyncTable.modeBlockedApps: '''
INSERT INTO mode_blocked_apps (mode_id, platform, app_identifier, created_at, updated_at)
VALUES (?, ?, ?, ?, ?)
ON CONFLICT(mode_id, platform, app_identifier) DO UPDATE SET
  created_at = excluded.created_at,
  updated_at = excluded.updated_at
''',
    SyncTable.schedules: '''
INSERT INTO schedules (id, mode_id, days, start_minute, end_minute, enabled, created_at, updated_at)
VALUES (?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  mode_id = excluded.mode_id,
  days = excluded.days,
  start_minute = excluded.start_minute,
  end_minute = excluded.end_minute,
  enabled = excluded.enabled,
  created_at = excluded.created_at,
  updated_at = excluded.updated_at
''',
    SyncTable.restrictionSessions: '''
INSERT INTO restriction_sessions (session_id, mode_id, source, started_at, ended_at,
  pause_count, total_paused_ms, last_paused_at, integrity_status, last_anomaly_reason,
  last_event_id, created_at, updated_at)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
''',
    SyncTable.restrictionLifecycleEvents: '''
INSERT INTO restriction_lifecycle_events (id, session_id, mode_id, action, source,
  reason, occurred_at, created_at)
VALUES (?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  session_id = excluded.session_id,
  mode_id = excluded.mode_id,
  action = excluded.action,
  source = excluded.source,
  reason = excluded.reason,
  occurred_at = excluded.occurred_at,
  created_at = excluded.created_at
''',
    SyncTable.nfcLinkedChips: '''
INSERT INTO nfc_linked_chips (id, chip_identifier, name, created_at, updated_at)
VALUES (?, ?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  chip_identifier = excluded.chip_identifier,
  name = excluded.name,
  created_at = excluded.created_at,
  updated_at = excluded.updated_at
''',
    SyncTable.qrLinkedCodes: '''
INSERT INTO qr_linked_codes (id, scan_value, name, created_at, updated_at)
VALUES (?, ?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  scan_value = excluded.scan_value,
  name = excluded.name,
  created_at = excluded.created_at,
  updated_at = excluded.updated_at
''',
    SyncTable.streakSessionDailyRollups: '''
INSERT INTO streak_session_daily_rollups (session_id, local_day, effective_ms, updated_at)
VALUES (?, ?, ?, ?)
ON CONFLICT(session_id, local_day) DO UPDATE SET
  effective_ms = excluded.effective_ms,
  updated_at = excluded.updated_at
''',
    SyncTable.streakDailyAggregates: '''
INSERT INTO streak_daily_aggregates (local_day, effective_ms, qualified, source_session_count, updated_at)
VALUES (?, ?, ?, ?, ?)
ON CONFLICT(local_day) DO UPDATE SET
  effective_ms = excluded.effective_ms,
  qualified = excluded.qualified,
  source_session_count = excluded.source_session_count,
  updated_at = excluded.updated_at
''',
  };
}
