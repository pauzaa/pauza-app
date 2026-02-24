import 'package:flutter/foundation.dart';

@immutable
class LocalDatabaseConfig {
  const LocalDatabaseConfig({
    this.name = 'pauza.db',
    this.version = 1,
    this.enableForeignKeys = true,
    this.logSql = false,
  });

  /// The canonical database configuration for the Pauza app.
  ///
  /// Both the foreground [PauzaDependencies] and background worker must use
  /// this constant to guarantee the same schema version is opened.
  static const LocalDatabaseConfig pauza = LocalDatabaseConfig(version: 4);

  final String name;
  final int version;
  final bool enableForeignKeys;
  final bool logSql;

  @override
  String toString() =>
      'LocalDatabaseConfig('
      'name: $name, '
      'version: $version, '
      'enableForeignKeys: $enableForeignKeys, '
      'logSql: $logSql'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalDatabaseConfig &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          version == other.version &&
          enableForeignKeys == other.enableForeignKeys &&
          logSql == other.logSql;

  @override
  int get hashCode => Object.hash(name, version, enableForeignKeys, logSql);
}
