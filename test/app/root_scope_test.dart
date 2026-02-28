import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
import 'package:pauza/src/core/connectivity/model/internet_health_state.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/auth/common/model/auth_credentials_dto.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';
import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_lifecycle_event_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_session_log.dart';
import 'package:pauza/src/features/stats/blocking_stats/data/stats_blocking_repository.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/mode_blocking_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/source_blocking_snapshot.dart';
import 'package:pauza/src/features/streaks/common/model/streak_snapshot.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:sqflite/sqflite.dart';

void main() {
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
  final dependencies = _TestPauzaDependencies(hasNfcSupport: hasNfcSupport);
  bool? observedHasNfcSupport;

  await tester.pumpWidget(
    MaterialApp(
      home: RootScope(
        dependencies: dependencies,
        child: Builder(
          builder: (context) {
            observedHasNfcSupport = RootScope.of(context).hasNfcSupport;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );

  await tester.pump();

  return observedHasNfcSupport;
}

final class _TestPauzaDependencies extends PauzaDependencies {
  _TestPauzaDependencies({required bool hasNfcSupport}) {
    localDatabase = _FakeLocalDatabase();
    appRestrictionManager = AppRestrictionManager();
    installedAppsManager = InstalledAppsManager();
    usageStatsManager = UsageStatsManager();
    restrictionLifecycleRepository = _FakeRestrictionLifecycleRepository();
    nfcRepository = _FakeNfcRepository();
    authRepository = _FakeAuthRepository();
    userProfileRepository = _FakeUserProfileRepository();
    streaksRepository = _FakeStreaksRepository();
    statsBlockingRepository = _FakeStatsBlockingRepository();
    internetHealthGate = _FakeInternetHealthGate();
    internetRequiredGuard = _FakeInternetRequiredGuard();
    this.hasNfcSupport = hasNfcSupport;
  }
}

final class _FakeInternetHealthGate implements InternetHealthGate {
  @override
  InternetHealthState get state => InternetHealthState.initial();

  @override
  bool get isHealthy => true;

  @override
  void addListener(VoidCallback listener) {}

  @override
  Future<void> refresh({bool force = false}) async {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void dispose() {}
}

final class _FakeInternetRequiredGuard implements InternetRequiredGuard {
  @override
  bool get isHealthy => true;

  @override
  Future<bool> canProceed({bool forceRefresh = true}) async => true;
}

final class _FakeLocalDatabase implements LocalDatabase {
  @override
  bool get isOpen => true;

  @override
  Future<void> close() async {}

  @override
  Future<void> open() async {}

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async => const [];

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<T> read<T>(Future<T> Function(DatabaseExecutor database) action) {
    throw UnimplementedError();
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction transaction) action) {
    throw UnimplementedError();
  }

  @override
  Future<T> write<T>(Future<T> Function(DatabaseExecutor database) action) {
    throw UnimplementedError();
  }
}

final class _FakeRestrictionLifecycleRepository implements RestrictionLifecycleRepository {
  @override
  Future<List<RestrictionLifecycleEventLog>> getEvents({String? modeId, String? sessionId, int limit = 500}) async {
    return const <RestrictionLifecycleEventLog>[];
  }

  @override
  Future<List<RestrictionSessionLog>> getSessions({String? modeId, int limit = 200}) async {
    return const <RestrictionSessionLog>[];
  }

  @override
  Future<void> syncFromPluginQueue({int batchSize = 200}) async {}
}

final class _FakeNfcRepository implements NfcRepository {
  @override
  bool get canOpenSystemSettingsForNfc => false;

  @override
  bool get isScanInProgress => false;

  @override
  Future<bool> hasNfcSupport() async => true;

  @override
  Future<NfcChipAvailability> getAvailability() async => NfcChipAvailability.available;

  @override
  Future<bool> openSystemSettingsForNfc() async => false;

  @override
  Future<NfcCardDto> scanSingleCard({Duration timeout = const Duration(seconds: 20)}) {
    throw UnimplementedError();
  }

  @override
  Future<void> stopSession({String? alertMessage, String? errorMessage}) async {}
}

final class _FakeAuthRepository implements AuthRepository {
  @override
  Session get currentSession => const Session.empty();

  @override
  Stream<Session> get sessionStream => const Stream<Session>.empty();

  @override
  Future<void> clearPendingOtpChallenge() async {}

  @override
  void dispose() {}

  @override
  Future<void> initialize() async {}

  @override
  Future<AuthResult> signIn(AuthCredentialsDto credentials) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthResult> verifyOtp({required String otp}) {
    throw UnimplementedError();
  }
}

final class _FakeUserProfileRepository implements UserProfileRepository {
  @override
  Future<void> clearCache() async {}

  @override
  Future<UserDto> fetchAndCacheProfile() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isUsernameAvailable({required String username}) {
    throw UnimplementedError();
  }

  @override
  Future<CachedUserProfile?> readCachedProfile() async => null;

  @override
  Future<String> uploadProfilePhoto({required String localFilePath}) {
    throw UnimplementedError();
  }

  @override
  Future<UserDto> updateProfile({
    required String name,
    required String username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<UserDto> watchProfileChanges() => const Stream<UserDto>.empty();
}

final class _FakeStreaksRepository implements StreaksRepository {
  @override
  Future<StreakSnapshot> getGlobalSnapshot({required DateTime nowLocal}) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshAggregates() async {}
}

final class _FakeStatsBlockingRepository implements StatsBlockingRepository {
  @override
  Future<BlockingStatsSnapshot> getBlockingSnapshot({required DateTimeRange window, required DateTime nowLocal}) {
    throw UnimplementedError();
  }

  @override
  Future<ModeBlockingSnapshot> getModeBreakdown({required DateTimeRange window}) {
    throw UnimplementedError();
  }

  @override
  Future<SourceBlockingSnapshot> getSourceBreakdown({required DateTimeRange window}) {
    throw UnimplementedError();
  }
}
