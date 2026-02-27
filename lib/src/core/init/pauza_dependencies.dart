import 'package:appfuse/appfuse.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/api_client/middleware/auth_mw.dart';
import 'package:pauza/src/core/api_client/middleware/logger_mw.dart';
import 'package:pauza/src/core/api_client/middleware/retry_mw.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate_notifier.dart';
import 'package:pauza/src/core/init/config.dart';
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
import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_scheduler.dart';
import 'package:pauza/src/features/stats/blocking_stats/data/stats_blocking_repository.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart'
    show AppRestrictionManager, InstalledAppsManager, PermissionManager, UsageStatsManager;

class PauzaDependencies with AppFuseInitialization {
  static final Uri _defaultInternetProbeUri = Uri.parse('https://www.google.com/');

  late final LocalDatabase localDatabase;
  late final InternetHealthGate internetHealthGate;
  late final PauzaPermissionGate permissionGate;
  late final PermissionManager permissionManager;
  late final InstalledAppsManager installedAppsManager;
  late final AppRestrictionManager appRestrictionManager;
  late final UsageStatsManager usageStatsManager;
  late final RestrictionLifecycleRepository restrictionLifecycleRepository;
  late final RestrictionLifecycleBackgroundScheduler restrictionLifecycleBackgroundScheduler;
  late final StreaksRepository streaksRepository;
  late final StatsBlockingRepository statsBlockingRepository;
  late final NfcRepository nfcRepository;
  late final bool hasNfcSupport;
  late final AuthSessionStorage authSessionStorage;
  late final FlutterSecureStorage secureStorage;
  late final IAppFuseStorage appFuseStorage;
  late final AuthRepository authRepository;
  late final PauzaAuthGate authGate;
  late final UserProfileCacheStorage userProfileCacheStorage;
  late final UserProfileRemoteDataSource userProfileRemoteDataSource;
  late final UserProfileRepository userProfileRepository;
  late final PackageInfo packageInfo;
  late final ApiClient apiClient;

  static PauzaDependencies of(BuildContext context) => AppFuseScope.of(context).init as PauzaDependencies;

  @override
  Map<String, InitializationStep> get steps => <String, InitializationStep>{
    'init local database': (_) async {
      localDatabase = SqfliteLocalDatabase(
        config: LocalDatabaseConfig.pauza,
        schema: const PauzaLocalDatabaseSchemaV1(),
      );
      await localDatabase.open();
    },
    'init api client': (state) async {
      apiClient = ApiClient(
        baseUrl: state.getCurrentConfig<PauzaConfig>()!.apiBaseUrl,
        middlewares: [
          const ApiClientLoggerMiddleware(),
          ApiClientAuthMiddleware(tokenProvider: () async => authRepository.currentSession.accessToken),
          const ApiClientRetryMiddleware(),
        ],
      );
    },
    'init internet health gate': (state) async {
      final config = state.getCurrentConfig<PauzaConfig>()!;
      internetHealthGate = InternetHealthGateNotifier(
        probeUri: _resolveInternetProbeUri(config),
        connectivity: Connectivity(),
      );
      await internetHealthGate.refresh(force: true);
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
    },
    'init user profile': (_) async {
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
      hasNfcSupport = await nfcRepository.hasNfcSupport();
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
        // Ignore startup refresh failures. Next resume/manual flow retries refresh.
      }
    },
    'init blocking stats repository': (_) async {
      statsBlockingRepository = StatsBlockingRepositoryImpl(
        localDatabase: localDatabase,
        streaksRepository: streaksRepository,
      );
    },
    'init restriction lifecycle background sync': (_) async {
      restrictionLifecycleBackgroundScheduler = WorkmanagerRestrictionLifecycleBackgroundScheduler();
      try {
        await restrictionLifecycleBackgroundScheduler.initializeAndScheduleDailySync();
      } on Object {
        // Ignore scheduling failures. Foreground startup/resume sync remains active.
      }
    },
  };

  static Uri _resolveInternetProbeUri(PauzaConfig config) {
    final configuredProbeUrl = config.internetProbeUrl;
    if (configuredProbeUrl != null) {
      final configuredProbeUri = Uri.tryParse(configuredProbeUrl);
      if (configuredProbeUri != null && configuredProbeUri.hasScheme) {
        return configuredProbeUri;
      }
    }

    final apiBaseUrl = config.apiBaseUrl.trim();
    if (apiBaseUrl.isNotEmpty) {
      final apiBaseUri = Uri.tryParse(apiBaseUrl);
      if (apiBaseUri != null && apiBaseUri.hasScheme) {
        return apiBaseUri;
      }
    }

    return _defaultInternetProbeUri;
  }
}
