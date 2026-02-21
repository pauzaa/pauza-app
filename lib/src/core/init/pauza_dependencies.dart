import 'package:appfuse/appfuse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';
import 'package:pauza/src/features/auth/domain/auth_gate.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/data/nfc_util_client.dart';
import 'package:pauza/src/features/permissions/domain/permission_gate.dart';
import 'package:pauza/src/features/profile/data/user_profile_cache_storage.dart';
import 'package:pauza/src/features/profile/data/user_profile_remote_data_source.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_plugin_client.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart'
    show AppRestrictionManager, InstalledAppsManager, PermissionManager, UsageStatsManager;

class PauzaDependencies with AppFuseInitialization {
  late final LocalDatabase localDatabase;
  late final PauzaPermissionGate permissionGate;
  late final PermissionManager permissionManager;
  late final InstalledAppsManager installedAppsManager;
  late final AppRestrictionManager appRestrictionManager;
  late final UsageStatsManager usageStatsManager;
  late final RestrictionLifecycleRepository restrictionLifecycleRepository;
  late final StreaksRepository streaksRepository;
  late final NfcRepository nfcRepository;
  late final AuthSessionStorage authSessionStorage;
  late final FlutterSecureStorage secureStorage;
  late final IAppFuseStorage appFuseStorage;
  late final AuthRepository authRepository;
  late final PauzaAuthGate authGate;
  late final UserProfileCacheStorage userProfileCacheStorage;
  late final UserProfileRemoteDataSource userProfileRemoteDataSource;
  late final UserProfileRepository userProfileRepository;
  late final PackageInfo packageInfo;

  static PauzaDependencies of(BuildContext context) => AppFuseScope.of(context).init as PauzaDependencies;

  @override
  Map<String, InitializationStep> get steps => <String, InitializationStep>{
    'init local database': (_) async {
      localDatabase = SqfliteLocalDatabase(
        config: const LocalDatabaseConfig(version: 4),
        schema: const PauzaLocalDatabaseSchemaV1(),
      );
      await localDatabase.open();
    },
    'init package info': (_) async {
      packageInfo = await PackageInfo.fromPlatform();
    },
    'init permissions': (_) async {
      permissionManager = PermissionManager();
      permissionGate = PauzaPermissionGateNotifier(permissionManager: permissionManager);
      await permissionGate.refresh(force: true);
    },
    'init auth': (_) async {
      secureStorage = const FlutterSecureStorage();
      authSessionStorage = SecureAuthSessionStorage(secureStorage: secureStorage);
      authRepository = AuthRepositoryImpl(sessionStorage: authSessionStorage);
      await authRepository.initialize();
      authGate = PauzaAuthGateNotifier(authRepository: authRepository);

      appFuseStorage = await AppFuseShPrStorage.init();
      userProfileCacheStorage = AppFuseUserProfileCacheStorage(storage: appFuseStorage);
      userProfileRemoteDataSource = const UserProfileRemoteDataSourceImpl();
      userProfileRepository = UserProfileRepositoryImpl(
        cacheStorage: userProfileCacheStorage,
        remoteDataSource: userProfileRemoteDataSource,
        nowUtc: () => DateTime.now().toUtc(),
      );
    },
    'init managers': (_) async {
      installedAppsManager = InstalledAppsManager();
      appRestrictionManager = AppRestrictionManager();
      usageStatsManager = UsageStatsManager();
      nfcRepository = NfcRepositoryImpl(managerClient: NfcUtilClient());
    },
    'init restriction lifecycle sync coordinator': (_) async {
      restrictionLifecycleRepository = RestrictionLifecycleRepositoryImpl(
        localDatabase: localDatabase,
        pluginClient: RestrictionLifecyclePluginClientImpl(restrictions: appRestrictionManager),
      );
      try {
        await restrictionLifecycleRepository.syncFromPluginQueue();
      } on Object {
        // Ignore startup sync failures. Next resume/manual flow retries ingestion.
      }
    },
    'init streaks repository': (_) async {
      streaksRepository = StreaksRepositoryImpl(localDatabase: localDatabase);
      try {
        await streaksRepository.refreshAggregates();
      } on Object {
        // Ignore startup refresh failures. Snapshot reads can refresh later.
      }
    },
  };
}
