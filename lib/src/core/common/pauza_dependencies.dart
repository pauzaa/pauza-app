import 'package:appfuse/appfuse.dart';
import 'package:flutter/widgets.dart';
import 'package:pauza/src/core/local_database/local_database.dart';

class PauzaDependencies with AppFuseInitialization {
  late final LocalDatabase localDatabase;

  static PauzaDependencies of(BuildContext context) =>
      AppFuseScope.of(context).init as PauzaDependencies;

  @override
  Map<String, InitializationStep> get steps => <String, InitializationStep>{
    'init local database': (_) async {
      localDatabase = SqfliteLocalDatabase(
        schema: const PauzaLocalDatabaseSchemaV1(),
      );
      await localDatabase.open();
    },
  };
}
