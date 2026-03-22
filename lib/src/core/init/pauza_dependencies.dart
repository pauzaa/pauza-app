import 'package:appfuse/appfuse.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/api_client/cache/cache_mw.dart';
import 'package:pauza/src/core/api_client/cache/cache_policy.dart';
import 'package:pauza/src/core/api_client/cache/http_cache_store.dart';
import 'package:pauza/src/core/api_client/middleware/auth_mw.dart';
import 'package:pauza/src/core/api_client/middleware/logger_mw.dart';
import 'package:pauza/src/core/api_client/middleware/retry_mw.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate_notifier.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
import 'package:pauza/src/core/init/config.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/ai/data/ai_repository.dart';
import 'package:pauza/src/features/ai/data/mock_ai_remote_data_source.dart';
import 'package:pauza/src/features/auth/data/auth_remote_data_source.dart';
import 'package:pauza/src/features/devices/data/devices_remote_data_source.dart';
import 'package:pauza/src/features/devices/data/devices_repository.dart';
import 'package:pauza/src/features/devices/domain/device_token_coordinator.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';
import 'package:pauza/src/features/auth/domain/auth_gate.dart';
import 'package:pauza/src/features/friends/data/friends_remote_data_source.dart';
import 'package:pauza/src/features/friends/data/friends_repository.dart';
import 'package:pauza/src/features/friends/data/mock_friends_remote_data_source.dart';
import 'package:pauza/src/features/leaderboard/data/leaderboard_remote_data_source.dart';
import 'package:pauza/src/features/leaderboard/data/leaderboard_repository.dart';
import 'package:pauza/src/features/leaderboard/data/mock_leaderboard_remote_data_source.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/data/nfc_util_client.dart';
import 'package:pauza/src/features/permissions/domain/permission_gate.dart';
import 'package:pauza/src/features/profile/data/user_profile_remote_data_source.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_plugin_client.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_scheduler.dart';
import 'package:pauza/src/features/stats/blocking_stats/data/stats_blocking_repository.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza/src/features/sync/data/sync_local_data_source.dart';
import 'package:pauza/src/features/subscription/data/purchases_data_source.dart';
import 'package:pauza/src/features/subscription/data/subscription_repository.dart';
import 'package:pauza/src/features/sync/data/sync_remote_data_source.dart';
import 'package:pauza/src/features/sync/data/sync_repository.dart';
import 'package:pauza/src/features/sync/domain/sync_trigger.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart'
    show AppRestrictionManager, InstalledAppsManager, PermissionManager, UsageStatsManager;

class PauzaDependencies with AppFuseInitialization {
  static final Uri _defaultInternetProbeUri = Uri.parse('https://www.google.com/');

  late final LocalDatabase localDatabase;
  late final InternetHealthGate internetHealthGate;
  late final InternetRequiredGuard internetRequiredGuard;
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
  late final AuthRemoteDataSource authRemoteDataSource;
  late final FlutterSecureStorage secureStorage;
  late final AuthRepository authRepository;
  late final PauzaAuthGate authGate;
  late final HttpCacheStore httpCacheStore;
  late final UserProfileRemoteDataSource userProfileRemoteDataSource;
  late final UserProfileRepository userProfileRepository;
  late final FriendsRemoteDataSource friendsRemoteDataSource;
  late final FriendsRepository friendsRepository;
  late final LeaderboardRemoteDataSource leaderboardRemoteDataSource;
  late final LeaderboardRepository leaderboardRepository;
  late final PackageInfo packageInfo;
  late final ApiClient apiClient;
  late final SyncLocalDataSource syncLocalDataSource;
  late final SyncRemoteDataSource syncRemoteDataSource;
  late final SyncRepository syncRepository;
  late final SyncTrigger syncTrigger;
  late final DevicesRemoteDataSource devicesRemoteDataSource;
  late final DevicesRepository devicesRepository;
  late final DeviceTokenCoordinator deviceTokenCoordinator;
  late final PurchasesDataSource purchasesDataSource;
  late final SubscriptionRepository subscriptionRepository;
  late final String revenueCatApiKey;
  late final AiRepository aiRepository;

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
    'init http cache': (_) async {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init('${dir.path}/hive');
      final box = await Hive.openBox<String>('http_cache');
      httpCacheStore = HiveHttpCacheStore(box: box);
    },
    'init api client': (state) async {
      apiClient = ApiClient(
        baseUrl: state.getCurrentConfig<PauzaConfig>()!.apiBaseUrl,
        middlewares: [
          const ApiClientLoggerMiddleware(),
          ApiClientAuthMiddleware(
            tokenProvider: () async {
              final token = authRepository.currentSession.accessToken;
              return token.isEmpty ? null : token;
            },
            tokenRefresher: (_) => authRepository.refreshSession(),
          ),
          ApiClientCacheMiddleware(
            cacheStore: httpCacheStore,
            policies: [
              CachePolicy(pattern: RegExp(r'/leaderboard/.*'), ttl: const Duration(minutes: 5)),
              CachePolicy(pattern: RegExp(r'/friends/search'), ttl: const Duration(minutes: 1)),
              CachePolicy(pattern: RegExp(r'/friends/.*/stats'), ttl: const Duration(minutes: 3)),
              CachePolicy(pattern: RegExp(r'/friends'), ttl: const Duration(minutes: 2)),
              CachePolicy(pattern: RegExp(r'/me'), ttl: const Duration(minutes: 10)),
            ],
          ),
          const ApiClientRetryMiddleware(),
        ],
      );
    },
    'init auth': (_) async {
      secureStorage = const FlutterSecureStorage();
      authSessionStorage = SecureAuthSessionStorage(secureStorage: secureStorage);
      authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
      authRepository = AuthRepositoryImpl(
        remoteDataSource: authRemoteDataSource,
        sessionStorage: authSessionStorage,
        onSignOutCleanup: () async {
          await deviceTokenCoordinator.unregisterCurrentToken();
          await syncLocalDataSource.clearAllSyncableTables();
          await httpCacheStore.clear();
        },
      );
      await authRepository.initialize();
      authGate = PauzaAuthGateNotifier(authRepository: authRepository);
    },
    'init sync': (_) async {
      syncLocalDataSource = SyncLocalDataSourceImpl(database: localDatabase);
      syncRemoteDataSource = SyncRemoteDataSourceImpl(apiClient: apiClient);
      syncRepository = SyncRepositoryImpl(localDataSource: syncLocalDataSource, remoteDataSource: syncRemoteDataSource);
      syncTrigger = SyncTriggerImpl();
    },
    'init internet health gate': (state) async {
      final config = state.getCurrentConfig<PauzaConfig>()!;
      internetHealthGate = InternetHealthGateNotifier(
        probeUri: _resolveInternetProbeUri(config),
        connectivity: Connectivity(),
      );
      await internetHealthGate.refresh(force: true);
      internetRequiredGuard = InternetRequiredGuardImpl(internetHealthGate: internetHealthGate);
    },
    'init package info': (_) async {
      packageInfo = await PackageInfo.fromPlatform();
    },
    'init permissions': (_) async {
      permissionManager = PermissionManager();
      permissionGate = PauzaPermissionGateNotifier(permissionManager: permissionManager);
      await permissionGate.refresh(force: true);
    },
    'init user profile': (_) async {
      userProfileRemoteDataSource = UserProfileRemoteDataSourceImpl(apiClient: apiClient);
      userProfileRepository = UserProfileRepositoryImpl(
        remoteDataSource: userProfileRemoteDataSource,
        onAccountDeleted: () async {
          await syncLocalDataSource.clearAllSyncableTables();
          await authRepository.signOut();
        },
      );
    },
    'init devices': (_) async {
      devicesRemoteDataSource = DevicesRemoteDataSourceImpl(apiClient: apiClient);
      devicesRepository = DevicesRepositoryImpl(remoteDataSource: devicesRemoteDataSource);
      deviceTokenCoordinator = DeviceTokenCoordinator(
        authRepository: authRepository,
        devicesRepository: devicesRepository,
      );
    },
    'init subscription': (state) async {
      revenueCatApiKey = state.getCurrentConfig<PauzaConfig>()!.revenueCatApiKey;
      purchasesDataSource = PurchasesDataSourceImpl();
      subscriptionRepository = SubscriptionRepositoryImpl(dataSource: purchasesDataSource, entitlementId: 'premium');
    },
    'init friends': (_) async {
      friendsRemoteDataSource =
          const MockFriendsRemoteDataSource(); // TODO() revert to FriendsRemoteDataSourceImpl(apiClient: apiClient)
      friendsRepository = FriendsRepositoryImpl(remoteDataSource: friendsRemoteDataSource);
    },
    'init leaderboard': (_) async {
      leaderboardRemoteDataSource =
          const MockLeaderboardRemoteDataSource(); // TODO() revert to LeaderboardRemoteDataSourceImpl(apiClient: apiClient)
      leaderboardRepository = LeaderboardRepositoryImpl(remoteDataSource: leaderboardRemoteDataSource);
    },
    'init ai': (_) async {
      const aiDataSource = MockAiRemoteDataSource(); // TODO() revert to AiRemoteDataSourceImpl(apiClient: apiClient)
      aiRepository = const AiRepositoryImpl(remoteDataSource: aiDataSource);
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
        syncTrigger: syncTrigger,
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
