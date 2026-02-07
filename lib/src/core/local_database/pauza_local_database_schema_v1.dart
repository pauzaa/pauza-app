import 'package:pauza/src/core/local_database/local_database_schema.dart';
import 'package:sqflite/sqflite.dart';

abstract final class LocalDatabaseSqlStatements {
  static const String createModesTable = '''
CREATE TABLE modes (
  id TEXT PRIMARY KEY NOT NULL,
  title TEXT NOT NULL,
  text_on_screen TEXT NOT NULL,
  description TEXT,
  allowed_pauses_count INTEGER NOT NULL DEFAULT 0
    CHECK (allowed_pauses_count >= 0),
  is_enabled INTEGER NOT NULL DEFAULT 1
    CHECK (is_enabled IN (0, 1)),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
''';

  static const String createModeBlockedAppsTable = '''
CREATE TABLE mode_blocked_apps (
  id TEXT PRIMARY KEY NOT NULL,
  mode_id TEXT NOT NULL REFERENCES modes(id) ON DELETE CASCADE,
  platform TEXT NOT NULL CHECK (platform IN ('android','ios')),
  app_identifier TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE (mode_id, platform, app_identifier)
);
''';
}

final class PauzaLocalDatabaseSchemaV1 implements LocalDatabaseSchema {
  const PauzaLocalDatabaseSchemaV1();

  @override
  Future<void> onConfigure(Database database) async {}

  @override
  Future<void> onCreate(Database database, int version) async {
    final batch = database.batch();
    batch.execute(LocalDatabaseSqlStatements.createModesTable);
    batch.execute(LocalDatabaseSqlStatements.createModeBlockedAppsTable);
    await batch.commit(noResult: true);
  }

  @override
  Future<void> onUpgrade(Database database, int oldVersion, int newVersion) async {}
}
