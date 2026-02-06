import 'package:appfuse/appfuse.dart';
import 'package:flutter/widgets.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/blocking/data/blocking_repository.dart';
import 'package:pauza/src/features/blocking/data/pauza_screen_time_blocking_repository.dart';
import 'package:pauza/src/features/modes/data/local_database_modes_repository.dart';
import 'package:pauza/src/features/modes/data/modes_repository.dart';

class PauzaDependencies with AppFuseInitialization {
  late final LocalDatabase localDatabase;
  late final ModesRepository modesRepository;
  late final BlockingRepository blockingRepository;

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
    'init repositories': (_) async {
      modesRepository = LocalDatabaseModesRepository(
        localDatabase: localDatabase,
      );
      blockingRepository = PauzaScreenTimeBlockingRepository();
    },
  };
}
