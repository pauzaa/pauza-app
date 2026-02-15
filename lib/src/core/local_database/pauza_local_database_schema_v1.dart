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
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
''';

  static const String createModeBlockedAppsTable = '''
CREATE TABLE mode_blocked_apps (
  mode_id TEXT NOT NULL REFERENCES modes(id) ON DELETE CASCADE,
  platform TEXT NOT NULL CHECK (platform IN ('android','ios')),
  app_identifier TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  PRIMARY KEY (mode_id, platform, app_identifier)
);
''';

  static const String createSchedulesTable = '''
CREATE TABLE schedules (
  id TEXT PRIMARY KEY NOT NULL,
  mode_id TEXT NOT NULL REFERENCES modes(id) ON DELETE CASCADE,
  days TEXT NOT NULL,
  start_minute INTEGER NOT NULL
    CHECK (start_minute BETWEEN 0 AND 1439),
  end_minute INTEGER NOT NULL
    CHECK (end_minute BETWEEN 0 AND 1439),
  enabled INTEGER NOT NULL DEFAULT 0
    CHECK (enabled IN (0, 1)),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE (mode_id)
);
''';

  static const String createRestrictionLifecycleEventsTable = '''
CREATE TABLE restriction_lifecycle_events (
  id TEXT PRIMARY KEY NOT NULL,
  session_id TEXT NOT NULL,
  mode_id TEXT NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('START', 'PAUSE', 'RESUME', 'END')),
  source TEXT NOT NULL CHECK (source IN ('manual', 'schedule')),
  reason TEXT NOT NULL,
  occurred_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);
''';

  static const String createRestrictionSessionsTable = '''
CREATE TABLE restriction_sessions (
  session_id TEXT PRIMARY KEY NOT NULL,
  mode_id TEXT NOT NULL,
  source TEXT NOT NULL CHECK (source IN ('manual', 'schedule')),
  started_at INTEGER NOT NULL,
  ended_at INTEGER,
  pause_count INTEGER NOT NULL DEFAULT 0,
  total_paused_ms INTEGER NOT NULL DEFAULT 0,
  last_paused_at INTEGER,
  integrity_status TEXT NOT NULL DEFAULT 'ok'
    CHECK (integrity_status IN ('ok', 'anomaly')),
  last_anomaly_reason TEXT,
  last_event_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
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
    batch.execute(LocalDatabaseSqlStatements.createSchedulesTable);
    batch.execute(
      LocalDatabaseSqlStatements.createRestrictionLifecycleEventsTable,
    );
    batch.execute(LocalDatabaseSqlStatements.createRestrictionSessionsTable);
    await batch.commit(noResult: true);
  }

  @override
  Future<void> onUpgrade(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {}
}
