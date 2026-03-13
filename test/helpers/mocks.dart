import 'package:mocktail/mocktail.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
import 'package:pauza/src/core/local_database/local_database_service.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';
import 'package:pauza/src/features/auth/domain/auth_gate.dart';
import 'package:pauza/src/features/friends/data/friends_repository.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/leaderboard/data/leaderboard_repository.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/select_apps/data/pauza_screen_time_installed_apps_repository.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/data/nfc_system_settings_launcher.dart';
import 'package:pauza/src/features/nfc/data/nfc_util_client.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_linked_chips_repository.dart';
import 'package:pauza/src/features/profile/data/user_profile_cache_storage.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_linked_codes_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_scheduler.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_worker.dart';
import 'package:pauza/src/features/stats/blocking_stats/data/stats_blocking_repository.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza/src/features/sync/data/sync_local_data_source.dart';
import 'package:pauza/src/features/sync/data/sync_remote_data_source.dart';
import 'package:pauza/src/features/sync/data/sync_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockInternetRequiredGuard extends Mock implements InternetRequiredGuard {}

class MockModesRepository extends Mock implements ModesRepository {}

class MockBlockingRepository extends Mock implements BlockingRepository {}

class MockNfcLinkedChipsRepository extends Mock implements NfcLinkedChipsRepository {}

class MockQrLinkedCodesRepository extends Mock implements QrLinkedCodesRepository {}

class MockStreaksRepository extends Mock implements StreaksRepository {}

class MockNfcRepository extends Mock implements NfcRepository {}

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

class MockRestrictionLifecycleRepository extends Mock implements RestrictionLifecycleRepository {}

class MockUserProfileCacheStorage extends Mock implements UserProfileCacheStorage {}

class MockAuthSessionStorage extends Mock implements AuthSessionStorage {}

class MockLocalDatabase extends Mock implements LocalDatabase {}

class MockInternetHealthGate extends Mock implements InternetHealthGate {}

class MockPauzaAuthGate extends Mock implements PauzaAuthGate {}

class MockNfcOperations extends Mock implements NfcOperations {}

class MockNfcManagerGateway extends Mock implements NfcManagerGateway {}

class MockNfcSystemSettingsLauncher extends Mock implements NfcSystemSettingsLauncher {}

class MockInstalledAppsRepository extends Mock implements InstalledAppsRepository {}

class MockRestrictionLifecycleBackgroundScheduler extends Mock implements RestrictionLifecycleBackgroundScheduler {}

class MockWorkmanagerClient extends Mock implements WorkmanagerClient {}

class MockRestrictionLifecycleBackgroundDependencies extends Mock
    implements RestrictionLifecycleBackgroundDependencies {}

class MockRestrictionLifecycleBackgroundDependenciesFactory extends Mock
    implements RestrictionLifecycleBackgroundDependenciesFactory {}

class MockStatsBlockingRepository extends Mock implements StatsBlockingRepository {}

class MockAppRestrictionManager extends Mock implements AppRestrictionManager {}

class MockInstalledAppsManager extends Mock implements InstalledAppsManager {}

class MockUsageStatsManager extends Mock implements UsageStatsManager {}

class MockFriendsRepository extends Mock implements FriendsRepository {}

class MockLeaderboardRepository extends Mock implements LeaderboardRepository {}

class MockSyncLocalDataSource extends Mock implements SyncLocalDataSource {}

class MockSyncRemoteDataSource extends Mock implements SyncRemoteDataSource {}

class MockSyncRepository extends Mock implements SyncRepository {}
