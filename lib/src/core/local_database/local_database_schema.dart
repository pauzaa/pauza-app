import 'package:sqflite/sqflite.dart';

abstract interface class LocalDatabaseSchema {
  Future<void> onConfigure(Database database);

  Future<void> onCreate(Database database, int version);

  Future<void> onUpgrade(Database database, int oldVersion, int newVersion);
}

class EmptyLocalDatabaseSchema implements LocalDatabaseSchema {
  const EmptyLocalDatabaseSchema();

  @override
  Future<void> onConfigure(Database database) async {}

  @override
  Future<void> onCreate(Database database, int version) async {}

  @override
  Future<void> onUpgrade(Database database, int oldVersion, int newVersion) async {}
}
