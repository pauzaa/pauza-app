import 'dart:async';

import 'package:pauza/src/core/common/disposable.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:sqflite/sqflite.dart' show Batch;
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/modes/common/model/schedule.dart';
import 'package:pauza/src/features/modes/common/model/week_day.dart';
import 'package:pauza/src/features/sync/common/model/sync_table.dart';
import 'package:pauza/src/features/sync/data/sync_local_data_source.dart';
import 'package:pauza/src/features/sync/domain/sync_trigger.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:uuid/uuid.dart';

abstract interface class ModesRepository implements Disposable {
  Future<List<Mode>> getModes();

  Future<Mode> getMode(String modeId);

  Future<void> createMode(ModeUpsertDTO request);

  Future<void> updateMode({required String modeId, required ModeUpsertDTO request});

  Future<void> deleteMode(String modeId);

  Future<void> reconcilePlugin({required bool isPremium});

  Stream<void> watchModes();

  void notifyExternalChange();
}

String _modeSelectQuery({String? whereClause}) =>
    '''
SELECT
  m.id,
  m.title,
  m.text_on_screen,
  m.description,
  m.allowed_pauses_count,
  m.minimum_duration_ms,
  m.ending_pausing_scenario,
  m.icon_token,
  m.created_at,
  m.updated_at,
  s.days AS schedule_days,
  s.start_minute AS schedule_start_minute,
  s.end_minute AS schedule_end_minute,
  s.enabled AS schedule_enabled,
  GROUP_CONCAT(ba.app_identifier) AS blocked_apps
FROM modes m
LEFT JOIN schedules s ON s.mode_id = m.id
LEFT JOIN mode_blocked_apps ba
  ON ba.mode_id = m.id AND ba.platform = ?
${whereClause != null ? 'WHERE $whereClause' : ''}
GROUP BY m.id
ORDER BY m.title ASC;
''';

class ModesRepositoryImpl implements ModesRepository {
  ModesRepositoryImpl({
    required LocalDatabase localDatabase,
    required this.platform,
    required AppRestrictionManager restrictions,
    SyncLocalDataSource? syncLocalDataSource,
    SyncTrigger? syncTrigger,
    Uuid? uuid,
  }) : _localDatabase = localDatabase,
       _restrictions = restrictions,
       _syncLocalDataSource = syncLocalDataSource,
       _syncTrigger = syncTrigger,
       _uuid = uuid ?? const Uuid();

  final LocalDatabase _localDatabase;
  final AppRestrictionManager _restrictions;
  final SyncLocalDataSource? _syncLocalDataSource;
  final SyncTrigger? _syncTrigger;
  final Uuid _uuid;
  final PauzaPlatform platform;

  StreamController<void>? _streamController;

  @override
  Future<List<Mode>> getModes() async {
    final rows = await _localDatabase.rawQuery(_modeSelectQuery(), [platform.dbValue]);

    if (rows.isEmpty) {
      return const [];
    }

    return rows.map(Mode.fromDbRow).toList(growable: false);
  }

  @override
  Future<Mode> getMode(String modeId) async {
    final rows = await _localDatabase.rawQuery(_modeSelectQuery(whereClause: 'm.id = ?'), [platform.dbValue, modeId]);

    if (rows.isEmpty) {
      throw Exception('Mode not found');
    }

    return Mode.fromDbRow(rows.first);
  }

  @override
  Future<void> deleteMode(String modeId) async {
    final previousMode = await getMode(modeId);
    await _localDatabase.rawDelete('DELETE FROM modes WHERE id = ?', [modeId]);

    try {
      await _restrictions.removeMode(modeId);
    } on Object {
      // Best-effort. reconcilePlugin on next startup will clean up.
    }

    await _trackModeDeletion(modeId, previousMode);
    await _notifyListeners();
    _syncTrigger?.notifyChange();
  }

  @override
  Future<void> createMode(ModeUpsertDTO request) async {
    final modeId = _uuid.v4();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _restrictions.upsertMode(request.toRestrictionMode(modeId: modeId));

    try {
      await _localDatabase.transaction((transaction) async {
        final batch = transaction.batch();
        batch.rawInsert(
          '''
INSERT INTO modes (
  id,
  title,
  text_on_screen,
          description,
          allowed_pauses_count,
          minimum_duration_ms,
          ending_pausing_scenario,
          icon_token,
          created_at,
          updated_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
          [
            modeId,
            request.title,
            request.textOnScreen,
            request.description,
            request.allowedPausesCount,
            request.minimumDuration?.inMilliseconds,
            request.endingPausingScenario.dbValue,
            request.icon.token,
            now,
            now,
          ],
        );

        final schedule = request.schedule;
        if (schedule != null) {
          _batchInsertSchedule(batch, modeId: modeId, schedule: schedule, now: now);
        }

        _batchInsertBlockedApps(batch, modeId: modeId, appIds: request.blockedAppIds.map((id) => id.raw), now: now);

        await batch.commit(noResult: true);
      });
    } on Object {
      try {
        await _restrictions.removeMode(modeId);
      } on Object {
        // Best-effort rollback to reduce plugin/DB drift.
      }
      rethrow;
    }

    await _notifyListeners();
    _syncTrigger?.notifyChange();
  }

  @override
  Future<void> updateMode({required String modeId, required ModeUpsertDTO request}) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final previousMode = await getMode(modeId);
    await _restrictions.upsertMode(request.toRestrictionMode(modeId: modeId));

    try {
      await _localDatabase.transaction((transaction) async {
        final schedule = request.schedule;
        final existingScheduleRows = await transaction.rawQuery('SELECT created_at FROM schedules WHERE mode_id = ?', [
          modeId,
        ]);
        final scheduleExists =
            existingScheduleRows.isNotEmpty && (existingScheduleRows.first['created_at'] as int?) != null;

        final existingBlockedRows = await transaction.rawQuery(
          'SELECT app_identifier FROM mode_blocked_apps WHERE mode_id = ? AND platform = ?',
          [modeId, platform.dbValue],
        );
        final existingBlocked = existingBlockedRows.map((row) => row['app_identifier']).whereType<String>().toSet();
        final requestedBlocked = request.blockedAppIds.map((id) => id.raw).toSet();
        final removedBlocked = existingBlocked.difference(requestedBlocked);
        final addedBlocked = requestedBlocked.difference(existingBlocked);

        final batch = transaction.batch();
        batch.rawUpdate(
          '''
UPDATE modes
SET
  title = ?,
  text_on_screen = ?,
  description = ?,
  allowed_pauses_count = ?,
  minimum_duration_ms = ?,
  ending_pausing_scenario = ?,
  icon_token = ?,
  updated_at = ?
WHERE id = ?
''',
          [
            request.title,
            request.textOnScreen,
            request.description,
            request.allowedPausesCount,
            request.minimumDuration?.inMilliseconds,
            request.endingPausingScenario.dbValue,
            request.icon.token,
            now,
            modeId,
          ],
        );

        if (schedule == null) {
          if (scheduleExists) {
            batch.rawDelete('DELETE FROM schedules WHERE mode_id = ?', [modeId]);
          }
        } else if (scheduleExists) {
          batch.rawUpdate(
            '''
UPDATE schedules
SET
  days = ?,
  start_minute = ?,
  end_minute = ?,
  enabled = ?,
  updated_at = ?
WHERE mode_id = ?
''',
            [
              WeekDay.encodeDays(schedule.days),
              schedule.start.toMinutesFromMidnight,
              schedule.end.toMinutesFromMidnight,
              schedule.enabled ? 1 : 0,
              now,
              modeId,
            ],
          );
        } else {
          _batchInsertSchedule(batch, modeId: modeId, schedule: schedule, now: now);
        }

        for (final appId in removedBlocked) {
          batch.rawDelete('DELETE FROM mode_blocked_apps WHERE mode_id = ? AND platform = ? AND app_identifier = ?', [
            modeId,
            platform.dbValue,
            appId,
          ]);
        }

        _batchInsertBlockedApps(batch, modeId: modeId, appIds: addedBlocked, now: now);

        await batch.commit(noResult: true);
      });
    } on Object {
      try {
        await _restrictions.upsertMode(previousMode.toRestrictionMode());
      } on Object {
        // Best-effort rollback to reduce plugin/DB drift.
      }
      rethrow;
    }

    await _trackUpdateDeletions(modeId: modeId, previousMode: previousMode, request: request);
    await _notifyListeners();
    _syncTrigger?.notifyChange();
  }

  @override
  Stream<void> watchModes() {
    _streamController ??= StreamController<void>.broadcast();
    return _streamController!.stream;
  }

  @override
  void notifyExternalChange() => _notifyListeners();

  Future<void> _notifyListeners() async {
    final controller = _streamController;
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(null);
  }

  Future<void> _trackModeDeletion(String modeId, Mode previousMode) async {
    final sync = _syncLocalDataSource;
    if (sync == null) return;

    await sync.trackDeletion(table: SyncTable.modes, key: modeId);
    if (previousMode.schedule != null) {
      await sync.trackDeletion(table: SyncTable.schedules, key: modeId);
    }
    for (final appId in previousMode.blockedAppIds) {
      await sync.trackDeletion(
        table: SyncTable.modeBlockedApps,
        key: <String, Object?>{'mode_id': modeId, 'platform': platform.dbValue, 'app_identifier': appId.raw},
      );
    }
  }

  Future<void> _trackUpdateDeletions({
    required String modeId,
    required Mode previousMode,
    required ModeUpsertDTO request,
  }) async {
    final sync = _syncLocalDataSource;
    if (sync == null) return;

    final previousBlocked = previousMode.blockedAppIds.map((id) => id.raw).toSet();
    final requestedBlocked = request.blockedAppIds.map((id) => id.raw).toSet();
    final removedBlocked = previousBlocked.difference(requestedBlocked);

    for (final appId in removedBlocked) {
      await sync.trackDeletion(
        table: SyncTable.modeBlockedApps,
        key: <String, Object?>{'mode_id': modeId, 'platform': platform.dbValue, 'app_identifier': appId},
      );
    }

    if (previousMode.schedule != null && request.schedule == null) {
      await sync.trackDeletion(table: SyncTable.schedules, key: modeId);
    }
  }

  @override
  Future<void> reconcilePlugin({required bool isPremium}) async {
    await _restrictions.setScheduleEnforcementEnabled(isPremium);
    final dbModes = await getModes();
    await _restrictions.replaceAllModes(dbModes.map((m) => m.toRestrictionMode()).toList());
  }

  void _batchInsertSchedule(Batch batch, {required String modeId, required Schedule schedule, required int now}) {
    batch.rawInsert(
      '''
INSERT INTO schedules (
  id,
  mode_id,
  days,
  start_minute,
  end_minute,
  enabled,
  created_at,
  updated_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
      [
        modeId,
        modeId,
        WeekDay.encodeDays(schedule.days),
        schedule.start.toMinutesFromMidnight,
        schedule.end.toMinutesFromMidnight,
        schedule.enabled ? 1 : 0,
        now,
        now,
      ],
    );
  }

  void _batchInsertBlockedApps(
    Batch batch, {
    required String modeId,
    required Iterable<String> appIds,
    required int now,
  }) {
    for (final appId in appIds) {
      batch.rawInsert(
        '''
INSERT INTO mode_blocked_apps (
  mode_id,
  platform,
  app_identifier,
  created_at,
  updated_at
) VALUES (?, ?, ?, ?, ?)
''',
        [modeId, platform.dbValue, appId, now, now],
      );
    }
  }

  @override
  void dispose() {
    _streamController?.close();
    _streamController = null;
  }
}
