import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/devices/domain/device_token_coordinator.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/sync/domain/sync_trigger.dart';

import '../helpers/helpers.dart';

void main() {
  setUpAll(registerTestFallbackValues);
  testWidgets('RootScope exposes hasNfcSupport from dependencies when true', (tester) async {
    final hasNfcSupport = await _pumpAndReadHasNfcSupport(tester, hasNfcSupport: true);

    expect(hasNfcSupport, isTrue);
  });

  testWidgets('RootScope exposes hasNfcSupport from dependencies when false', (tester) async {
    final hasNfcSupport = await _pumpAndReadHasNfcSupport(tester, hasNfcSupport: false);

    expect(hasNfcSupport, isFalse);
  });
}

Future<bool?> _pumpAndReadHasNfcSupport(WidgetTester tester, {required bool hasNfcSupport}) async {
  final dependencies = _buildTestDependencies(hasNfcSupport: hasNfcSupport);
  bool? observedHasNfcSupport;

  await tester.pumpApp(
    RootScope(
      dependencies: dependencies,
      child: Builder(
        builder: (context) {
          observedHasNfcSupport = RootScope.of(context).hasNfcSupport;
          return const SizedBox.shrink();
        },
      ),
    ),
  );

  return observedHasNfcSupport;
}

_TestPauzaDependencies _buildTestDependencies({required bool hasNfcSupport}) {
  final authRepository = MockAuthRepository();
  when(() => authRepository.currentSession).thenReturn(const Session.empty());
  when(() => authRepository.sessionStream).thenAnswer((_) => const Stream<Session>.empty());

  final userProfileRepository = MockUserProfileRepository();
  when(() => userProfileRepository.watchProfileChanges()).thenAnswer((_) => const Stream<UserDto>.empty());

  final internetRequiredGuard = MockInternetRequiredGuard();
  when(() => internetRequiredGuard.isHealthy).thenReturn(true);

  return _TestPauzaDependencies(
    hasNfcSupport: hasNfcSupport,
    authRepository: authRepository,
    userProfileRepository: userProfileRepository,
    internetRequiredGuard: internetRequiredGuard,
  );
}

final class _TestPauzaDependencies extends PauzaDependencies {
  _TestPauzaDependencies({
    required bool hasNfcSupport,
    required MockAuthRepository authRepository,
    required MockUserProfileRepository userProfileRepository,
    required MockInternetRequiredGuard internetRequiredGuard,
  }) {
    localDatabase = MockLocalDatabase();
    appRestrictionManager = MockAppRestrictionManager();
    installedAppsManager = MockInstalledAppsManager();
    usageStatsManager = MockUsageStatsManager();
    restrictionLifecycleRepository = MockRestrictionLifecycleRepository();
    nfcRepository = MockNfcRepository();
    this.authRepository = authRepository;
    this.userProfileRepository = userProfileRepository;
    streaksRepository = MockStreaksRepository();
    statsBlockingRepository = MockStatsBlockingRepository();
    internetHealthGate = MockInternetHealthGate();
    when(() => internetHealthGate.addListener(any())).thenReturn(null);
    when(() => internetHealthGate.removeListener(any())).thenReturn(null);
    this.internetRequiredGuard = internetRequiredGuard;
    syncTrigger = SyncTriggerImpl();
    this.hasNfcSupport = hasNfcSupport;
    aiRepository = MockAiRepository();
    syncLocalDataSource = MockSyncLocalDataSource();
    syncRemoteDataSource = MockSyncRemoteDataSource();
    syncRepository = MockSyncRepository();
    friendsRepository = MockFriendsRepository();
    leaderboardRepository = MockLeaderboardRepository();
    subscriptionRepository = MockSubscriptionRepository();
    revenueCatApiKey = 'test-key';
    deviceTokenCoordinator = DeviceTokenCoordinator(
      authRepository: authRepository,
      devicesRepository: MockDevicesRepository(),
    );
  }
}
