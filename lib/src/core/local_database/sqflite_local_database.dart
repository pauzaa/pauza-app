import 'package:path/path.dart' as p;
import 'package:pauza/src/core/local_database/local_database_config.dart';
import 'package:pauza/src/core/local_database/local_database_schema.dart';
import 'package:pauza/src/core/local_database/local_database_service.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteLocalDatabase implements LocalDatabase {
  SqfliteLocalDatabase({
    LocalDatabaseConfig config = const LocalDatabaseConfig(),
    LocalDatabaseSchema schema = const EmptyLocalDatabaseSchema(),
  }) : _config = config,
       _schema = schema;

  final LocalDatabaseConfig _config;
  final LocalDatabaseSchema _schema;

  Database? _database;
  Future<void>? _opening;

  @override
  bool get isOpen => _database?.isOpen ?? false;

  @override
  Future<void> open() async {
    if (isOpen) {
      return;
    }
    if (_opening != null) {
      return _opening;
    }

    final openOperation = _openInternal();
    _opening = openOperation;
    try {
      await openOperation;
    } finally {
      _opening = null;
    }
  }

  @override
  Future<void> close() async {
    final database = _database;
    _database = null;

    if (database == null) {
      return;
    }

    await database.close();
  }

  @override
  Future<T> read<T>(Future<T> Function(DatabaseExecutor database) action) async {
    await open();
    return action(_requireDatabase());
  }

  @override
  Future<T> write<T>(Future<T> Function(DatabaseExecutor database) action) async =>
      transaction((transaction) => action(transaction));

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction transaction) action) async {
    await open();
    return _requireDatabase().transaction(action);
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) =>
      read((database) => database.rawQuery(sql, arguments));

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) =>
      write((database) => database.rawInsert(sql, arguments));

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) =>
      write((database) => database.rawUpdate(sql, arguments));

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) =>
      write((database) => database.rawDelete(sql, arguments));

  Future<void> _openInternal() async {
    final databasesPath = await getDatabasesPath();
    final databasePath = p.join(databasesPath, _config.name);

    _database = await openDatabase(
      databasePath,
      version: _config.version,
      onConfigure: (database) async {
        await _schema.onConfigure(database);

        if (_config.enableForeignKeys) {
          await database.execute('PRAGMA foreign_keys = ON');
        }
      },
      onCreate: (database, version) async {
        await _schema.onCreate(database, version);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        await _schema.onUpgrade(database, oldVersion, newVersion);
      },
      onDowngrade: (database, oldVersion, newVersion) {
        throw UnsupportedError(
          'Database downgrade is not supported: '
          '$oldVersion -> $newVersion',
        );
      },
    );
  }

  Database _requireDatabase() {
    final database = _database;
    if (database == null) {
      throw StateError('Local database is not available. Call open() before usage.');
    }
    return database;
  }
}
