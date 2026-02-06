import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/modes/data/modes_repository.dart';
import 'package:pauza/src/features/modes/model/mode.dart';
import 'package:pauza/src/features/modes/model/mode_summary.dart';

class LocalDatabaseModesRepository implements ModesRepository {
  const LocalDatabaseModesRepository({required LocalDatabase localDatabase})
    : _localDatabase = localDatabase;

  final LocalDatabase _localDatabase;

  @override
  Future<List<ModeSummary>> listSummaries({
    required PauzaPlatform platform,
  }) async {
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
FROM ${LocalDatabaseTableNames.modes} m
LEFT JOIN ${LocalDatabaseTableNames.modeBlockedApps} mba
  ON mba.mode_id = m.id AND mba.platform = ?
GROUP BY m.id
ORDER BY m.updated_at DESC
''',
      [platform.dbValue],
    );

    return rows
        .map(
          (row) => ModeSummary(
            mode: _modeFromRow(row),
            blockedAppsCount: _asInt(row['blocked_apps_count']),
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
FROM ${LocalDatabaseTableNames.modes}
WHERE id = ?
LIMIT 1
''',
      [modeId],
    );

    if (rows.isEmpty) {
      return null;
    }

    return _modeFromRow(rows.first);
  }

  @override
  Future<List<String>> listBlockedAppIds(
    String modeId,
    PauzaPlatform platform,
  ) async {
    final rows = await _localDatabase.rawQuery(
      '''
SELECT app_identifier
FROM ${LocalDatabaseTableNames.modeBlockedApps}
WHERE mode_id = ? AND platform = ?
ORDER BY updated_at DESC
''',
      [modeId, platform.dbValue],
    );

    return rows
        .map((row) => row['app_identifier'])
        .whereType<String>()
        .toList(growable: false);
  }

  @override
  Future<void> deleteMode(String modeId) async {
    await _localDatabase.rawDelete(
      'DELETE FROM ${LocalDatabaseTableNames.modes} WHERE id = ?',
      [modeId],
    );
  }

  Mode _modeFromRow(Map<String, Object?> row) {
    return Mode(
      id: row['id']! as String,
      title: row['title']! as String,
      textOnScreen: row['text_on_screen']! as String,
      description: row['description'] as String?,
      allowedPausesCount: _asInt(row['allowed_pauses_count']),
      isEnabled: _asInt(row['is_enabled']) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(_asInt(row['created_at'])),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(_asInt(row['updated_at'])),
    );
  }

  int _asInt(Object? value) => switch (value) {
    final int i => i,
    final num n => n.toInt(),
    _ => 0,
  };
}
