import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/modes/common/model/schedule.dart';
import 'package:pauza/src/features/modes/common/model/week_day.dart';
import 'package:uuid/uuid.dart';

abstract interface class ModesRepository {
  Future<List<Mode>> getModes();

  Future<Mode> getMode(String modeId);

  Future<void> createMode(ModeUpsertDTO request);

  Future<void> updateMode({required String modeId, required ModeUpsertDTO request});

  Future<void> deleteMode(String modeId);
}

class ModesRepositoryImpl implements ModesRepository {
  const ModesRepositoryImpl({
    required LocalDatabase localDatabase,
    required this.platform,
    Uuid? uuid,
  }) : _localDatabase = localDatabase,
       _uuid = uuid ?? const Uuid();

  // ignore: unused_field
  final LocalDatabase _localDatabase;
  // ignore: unused_field
  final Uuid _uuid;
  final PauzaPlatform platform;

  @override
  Future<List<Mode>> getModes() async {
    final rows = await _localDatabase.rawQuery(
      '''
SELECT
  m.id,
  m.title,
  m.text_on_screen,
  m.description,
  m.allowed_pauses_count,
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
GROUP BY m.id
ORDER BY m.title ASC;
''',
      [platform.dbValue],
    );

    if (rows.isEmpty) {
      return const [];
    }

    return rows.map(Mode.fromDbRow).toList(growable: false);
  }

  @override
  Future<Mode> getMode(String modeId) async {
    final rows = await _localDatabase.rawQuery(
      '''
SELECT
  m.id,
  m.title,
  m.text_on_screen,
  m.description,
  m.allowed_pauses_count,
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
WHERE m.id = ?
GROUP BY m.id;
''',
      [platform.dbValue, modeId],
    );

    if (rows.isEmpty) {
      throw Exception('Mode not found');
    }

    return Mode.fromDbRow(rows.first);
  }

  @override
  Future<void> deleteMode(String modeId) async {
    await _localDatabase.rawDelete('DELETE FROM modes WHERE id = ?', [modeId]);
  }

  @override
  Future<void> createMode(ModeUpsertDTO request) async {
    final modeId = _uuid.v4();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

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
          icon_token,
          created_at,
          updated_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
        [
          modeId,
          request.title,
          request.textOnScreen,
          request.description,
          request.allowedPausesCount,
          request.icon.token,
          now,
          now,
        ],
      );

      final schedule = request.schedule;
      if (schedule != null) {
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

      if (request.blockedAppIds.isNotEmpty) {
        for (final appId in request.blockedAppIds) {
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
            [modeId, platform.dbValue, appId.raw, now, now],
          );
        }
      }

      await batch.commit(noResult: true);
    });
  }

  @override
  Future<void> updateMode({required String modeId, required ModeUpsertDTO request}) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    await _localDatabase.transaction((transaction) async {
      final schedule = request.schedule;
      final existingScheduleRows = await transaction.rawQuery(
        'SELECT created_at FROM schedules WHERE mode_id = ?',
        [modeId],
      );
      final scheduleExists =
          existingScheduleRows.isNotEmpty &&
          (existingScheduleRows.first['created_at'] as int?) != null;

      final existingBlockedRows = await transaction.rawQuery(
        'SELECT app_identifier FROM mode_blocked_apps WHERE mode_id = ? AND platform = ?',
        [modeId, platform.dbValue],
      );
      final existingBlocked = existingBlockedRows
          .map((row) => row['app_identifier'])
          .whereType<String>()
          .toSet();
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
  icon_token = ?,
  updated_at = ?
WHERE id = ?
''',
        [
          request.title,
          request.textOnScreen,
          request.description,
          request.allowedPausesCount,
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

      for (final appId in removedBlocked) {
        batch.rawDelete(
          'DELETE FROM mode_blocked_apps WHERE mode_id = ? AND platform = ? AND app_identifier = ?',
          [modeId, platform.dbValue, appId],
        );
      }

      for (final appId in addedBlocked) {
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

      await batch.commit(noResult: true);
    });
  }
}
