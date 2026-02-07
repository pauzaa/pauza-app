import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_summary.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert_request.dart';
import 'package:uuid/uuid.dart';

abstract interface class ModesRepository {
  Future<List<ModeSummary>> listSummaries({required PauzaPlatform platform});

  Future<Mode?> getMode(String modeId);

  Future<List<String>> listBlockedAppIds(String modeId, PauzaPlatform platform);

  Future<void> createMode({required ModeUpsertDTO request, required PauzaPlatform platform});

  Future<void> updateMode({
    required String modeId,
    required ModeUpsertDTO request,
    required PauzaPlatform platform,
  });

  Future<void> deleteMode(String modeId);
}

class ModesRepositoryImpl implements ModesRepository {
  ModesRepositoryImpl({required LocalDatabase localDatabase, Uuid? uuid})
    : _localDatabase = localDatabase,
      _uuid = uuid ?? const Uuid();

  final LocalDatabase _localDatabase;
  final Uuid _uuid;

  @override
  Future<List<ModeSummary>> listSummaries({required PauzaPlatform platform}) async {
    final rows = await _localDatabase.rawQuery(
      '''
SELECT
  m.id,
  m.title,
  m.text_on_screen,
  m.description,
  m.allowed_pauses_count,
  m.is_enabled,
  m.created_at,
  m.updated_at,
  COUNT(mba.id) AS blocked_apps_count
FROM modes m
LEFT JOIN mode_blocked_apps mba
  ON mba.mode_id = m.id AND mba.platform = ?
GROUP BY m.id
ORDER BY m.updated_at DESC
''',
      [platform.dbValue],
    );

    return rows
        .map(
          (row) => ModeSummary(
            mode: Mode.fromMap(row),
            blockedAppsCount: int.tryParse(row['blocked_apps_count'].toString()) ?? 0,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Mode?> getMode(String modeId) async {
    final rows = await _localDatabase.rawQuery(
      '''
SELECT
  id,
  title,
  text_on_screen,
  description,
  allowed_pauses_count,
  is_enabled,
  created_at,
  updated_at
FROM modes
WHERE id = ?
LIMIT 1
''',
      [modeId],
    );

    if (rows.isEmpty) {
      return null;
    }

    return Mode.fromMap(rows.first);
  }

  @override
  Future<List<String>> listBlockedAppIds(String modeId, PauzaPlatform platform) async {
    final rows = await _localDatabase.rawQuery(
      '''
SELECT app_identifier
FROM mode_blocked_apps
WHERE mode_id = ? AND platform = ?
ORDER BY updated_at DESC
''',
      [modeId, platform.dbValue],
    );

    return rows.map((row) => row['app_identifier']).whereType<String>().toList(growable: false);
  }

  @override
  Future<void> deleteMode(String modeId) async {
    await _localDatabase.rawDelete('DELETE FROM modes WHERE id = ?', [modeId]);
    await _localDatabase.rawDelete('DELETE FROM mode_blocked_apps WHERE mode_id = ?', [modeId]);
  }

  @override
  Future<void> createMode({required ModeUpsertDTO request, required PauzaPlatform platform}) async {
    final modeId = _uuid.v4();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final blockedAppIds = request.blockedAppIds.toList(growable: false);
    final normalizedDescription = request.description?.trim();

    await _localDatabase.transaction((transaction) async {
      final batch = transaction.batch();
      batch.insert('modes', {
        'id': modeId,
        'title': request.title,
        'text_on_screen': request.textOnScreen,
        'description': normalizedDescription,
        'allowed_pauses_count': request.allowedPausesCount,
        'is_enabled': request.isEnabled ? 1 : 0,
        'created_at': nowMs,
        'updated_at': nowMs,
      });

      for (final blockedAppId in blockedAppIds) {
        batch.insert('mode_blocked_apps', {
          'id': _uuid.v4(),
          'mode_id': modeId,
          'platform': platform.dbValue,
          'app_identifier': blockedAppId,
          'created_at': nowMs,
          'updated_at': nowMs,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<void> updateMode({
    required String modeId,
    required ModeUpsertDTO request,
    required PauzaPlatform platform,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final normalizedDescription = request.description?.trim();

    await _localDatabase.transaction((transaction) async {
      final batch = transaction.batch();
      batch.update(
        'modes',
        {
          'title': request.title,
          'text_on_screen': request.textOnScreen,
          'description': normalizedDescription,
          'allowed_pauses_count': request.allowedPausesCount,
          'is_enabled': request.isEnabled ? 1 : 0,
          'updated_at': nowMs,
        },
        where: 'id = ?',
        whereArgs: [modeId],
      );

      final existingRows = await transaction.rawQuery(
        '''
SELECT app_identifier
FROM mode_blocked_apps
WHERE mode_id = ? AND platform = ?
''',
        <Object?>[modeId, platform.dbValue],
      );
      final existing = existingRows.map((row) => row['app_identifier']).whereType<String>().toSet();

      final target = request.blockedAppIds.toSet();

      final toAdd = target.difference(existing);
      final toRemove = existing.difference(target);

      if (toRemove.isNotEmpty) {
        for (final blockedAppId in toRemove) {
          batch.delete(
            'mode_blocked_apps',
            where: 'mode_id = ? AND platform = ? AND app_identifier = ?',
            whereArgs: [modeId, platform.dbValue, blockedAppId],
          );
        }
      }

      for (final blockedAppId in toAdd) {
        batch.insert('mode_blocked_apps', {
          'id': _uuid.v4(),
          'mode_id': modeId,
          'platform': platform.dbValue,
          'app_identifier': blockedAppId,
          'created_at': nowMs,
          'updated_at': nowMs,
        });
      }
      await batch.commit(noResult: true);
    });
  }
}
