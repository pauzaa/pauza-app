import 'dart:developer' as developer;

import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_plugin_client.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:workmanager/workmanager.dart';

const String restrictionLifecycleBackgroundTaskUniqueName = 'restriction_lifecycle_daily_sync';
const String restrictionLifecycleBackgroundTaskIdentifier = 'com.menace.pauza.restriction_lifecycle_daily_sync';

@pragma('vm:entry-point')
void restrictionLifecycleBackgroundCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // iOS sends Workmanager.iOSBackgroundTask instead of the custom identifier.
    if (task != restrictionLifecycleBackgroundTaskIdentifier && task != Workmanager.iOSBackgroundTask) {
      return true;
    }

    final worker = RestrictionLifecycleBackgroundWorker();
    final result = await worker.run();
    return result == RestrictionLifecycleBackgroundTaskResult.success;
  });
}

enum RestrictionLifecycleBackgroundTaskResult { success, retry }

abstract interface class RestrictionLifecycleBackgroundDependencies {
  AuthSessionStorage get authSessionStorage;
  RestrictionLifecycleRepository get restrictionLifecycleRepository;
  StreaksRepository get streaksRepository;

  Future<void> close();
}

abstract interface class RestrictionLifecycleBackgroundDependenciesFactory {
  Future<RestrictionLifecycleBackgroundDependencies> create();
}

final class RestrictionLifecycleBackgroundWorker {
  RestrictionLifecycleBackgroundWorker({RestrictionLifecycleBackgroundDependenciesFactory? dependenciesFactory})
    : _dependenciesFactory = dependenciesFactory ?? const _DefaultRestrictionLifecycleBackgroundDependenciesFactory();

  final RestrictionLifecycleBackgroundDependenciesFactory _dependenciesFactory;

  Future<RestrictionLifecycleBackgroundTaskResult> run() async {
    RestrictionLifecycleBackgroundDependencies? dependencies;
    try {
      dependencies = await _dependenciesFactory.create();
      final session = await dependencies.authSessionStorage.readSession();
      if (!session.isAuthenticated) {
        developer.log('Skipped: no authenticated session.', name: 'BackgroundSync');
        return RestrictionLifecycleBackgroundTaskResult.success;
      }

      try {
        await dependencies.restrictionLifecycleRepository.syncFromPluginQueue();
        await dependencies.streaksRepository.refreshAggregates();
        return RestrictionLifecycleBackgroundTaskResult.success;
      } on Object catch (error, stackTrace) {
        developer.log(
          'Retry: sync failed with recoverable error.',
          name: 'BackgroundSync',
          error: error,
          stackTrace: stackTrace,
        );
        return RestrictionLifecycleBackgroundTaskResult.retry;
      }
    } on Object catch (error, stackTrace) {
      developer.log(
        'Success (non-recoverable setup error, will not retry).',
        name: 'BackgroundSync',
        error: error,
        stackTrace: stackTrace,
      );
      return RestrictionLifecycleBackgroundTaskResult.success;
    } finally {
      await dependencies?.close();
    }
  }
}

final class _DefaultRestrictionLifecycleBackgroundDependenciesFactory
    implements RestrictionLifecycleBackgroundDependenciesFactory {
  const _DefaultRestrictionLifecycleBackgroundDependenciesFactory();

  @override
  Future<RestrictionLifecycleBackgroundDependencies> create() async {
    final localDatabase = SqfliteLocalDatabase(
      config: LocalDatabaseConfig.pauza,
      schema: const PauzaLocalDatabaseSchemaV1(),
    );
    await localDatabase.open();

    final restrictions = AppRestrictionManager();
    final restrictionLifecycleRepository = RestrictionLifecycleRepositoryImpl(
      localDatabase: localDatabase,
      pluginClient: RestrictionLifecyclePluginClientImpl(restrictions: restrictions),
    );
    final streaksRepository = StreaksRepositoryImpl(localDatabase: localDatabase);

    return _DefaultRestrictionLifecycleBackgroundDependencies(
      authSessionStorage: SecureAuthSessionStorage(),
      restrictionLifecycleRepository: restrictionLifecycleRepository,
      streaksRepository: streaksRepository,
      localDatabase: localDatabase,
    );
  }
}

final class _DefaultRestrictionLifecycleBackgroundDependencies implements RestrictionLifecycleBackgroundDependencies {
  _DefaultRestrictionLifecycleBackgroundDependencies({
    required this.authSessionStorage,
    required this.restrictionLifecycleRepository,
    required this.streaksRepository,
    required LocalDatabase localDatabase,
  }) : _localDatabase = localDatabase;

  @override
  final AuthSessionStorage authSessionStorage;
  @override
  final RestrictionLifecycleRepository restrictionLifecycleRepository;
  @override
  final StreaksRepository streaksRepository;

  final LocalDatabase _localDatabase;

  @override
  Future<void> close() => _localDatabase.close();
}
