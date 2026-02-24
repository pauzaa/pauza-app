import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_lifecycle_event_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_session_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_worker.dart';
import 'package:pauza/src/features/streaks/common/model/streak_snapshot.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';

void main() {
  group('RestrictionLifecycleBackgroundWorker', () {
    test('returns success and skips sync when session is not authenticated', () async {
      final dependencies = _FakeBackgroundDependencies(
        authSessionStorage: _FakeAuthSessionStorage(session: const Session.empty()),
        restrictionLifecycleRepository: _FakeRestrictionLifecycleRepository(),
        streaksRepository: _FakeStreaksRepository(),
      );
      final worker = RestrictionLifecycleBackgroundWorker(
        dependenciesFactory: _FakeDependenciesFactory(dependencies: dependencies),
      );

      final result = await worker.run();

      expect(result, RestrictionLifecycleBackgroundTaskResult.success);
      expect(dependencies.restrictionLifecycleRepository.syncCallCount, 0);
      expect(dependencies.streaksRepository.refreshCallCount, 0);
      expect(dependencies.closeCallCount, 1);
    });

    test('returns success when sync and refresh succeed', () async {
      final dependencies = _FakeBackgroundDependencies(
        authSessionStorage: _FakeAuthSessionStorage(
          session: const Session(accessToken: 'token', refreshToken: 'refresh'),
        ),
        restrictionLifecycleRepository: _FakeRestrictionLifecycleRepository(),
        streaksRepository: _FakeStreaksRepository(),
      );
      final worker = RestrictionLifecycleBackgroundWorker(
        dependenciesFactory: _FakeDependenciesFactory(dependencies: dependencies),
      );

      final result = await worker.run();

      expect(result, RestrictionLifecycleBackgroundTaskResult.success);
      expect(dependencies.restrictionLifecycleRepository.syncCallCount, 1);
      expect(dependencies.streaksRepository.refreshCallCount, 1);
      expect(dependencies.closeCallCount, 1);
    });

    test('returns retry when sync fails after authenticated setup', () async {
      final dependencies = _FakeBackgroundDependencies(
        authSessionStorage: _FakeAuthSessionStorage(
          session: const Session(accessToken: 'token', refreshToken: 'refresh'),
        ),
        restrictionLifecycleRepository: _FakeRestrictionLifecycleRepository(
          onSync: () async => throw StateError('sync_failed'),
        ),
        streaksRepository: _FakeStreaksRepository(),
      );
      final worker = RestrictionLifecycleBackgroundWorker(
        dependenciesFactory: _FakeDependenciesFactory(dependencies: dependencies),
      );

      final result = await worker.run();

      expect(result, RestrictionLifecycleBackgroundTaskResult.retry);
      expect(dependencies.restrictionLifecycleRepository.syncCallCount, 1);
      expect(dependencies.streaksRepository.refreshCallCount, 0);
      expect(dependencies.closeCallCount, 1);
    });

    test('returns success when dependencies setup fails', () async {
      final worker = RestrictionLifecycleBackgroundWorker(dependenciesFactory: const _ThrowingDependenciesFactory());

      final result = await worker.run();

      expect(result, RestrictionLifecycleBackgroundTaskResult.success);
    });
  });
}

final class _FakeDependenciesFactory implements RestrictionLifecycleBackgroundDependenciesFactory {
  const _FakeDependenciesFactory({required this.dependencies});

  final _FakeBackgroundDependencies dependencies;

  @override
  Future<RestrictionLifecycleBackgroundDependencies> create() async => dependencies;
}

final class _ThrowingDependenciesFactory implements RestrictionLifecycleBackgroundDependenciesFactory {
  const _ThrowingDependenciesFactory();

  @override
  Future<RestrictionLifecycleBackgroundDependencies> create() async {
    throw StateError('setup_failed');
  }
}

final class _FakeBackgroundDependencies implements RestrictionLifecycleBackgroundDependencies {
  _FakeBackgroundDependencies({
    required this.authSessionStorage,
    required this.restrictionLifecycleRepository,
    required this.streaksRepository,
  });

  @override
  final AuthSessionStorage authSessionStorage;
  @override
  final _FakeRestrictionLifecycleRepository restrictionLifecycleRepository;
  @override
  final _FakeStreaksRepository streaksRepository;

  int closeCallCount = 0;

  @override
  Future<void> close() async {
    closeCallCount += 1;
  }
}

final class _FakeAuthSessionStorage implements AuthSessionStorage {
  _FakeAuthSessionStorage({required this.session});

  final Session session;

  @override
  Future<void> deleteSession() {
    throw UnimplementedError();
  }

  @override
  Future<Session> readSession() async => session;

  @override
  Future<void> writeSession(Session session) {
    throw UnimplementedError();
  }
}

final class _FakeRestrictionLifecycleRepository implements RestrictionLifecycleRepository {
  _FakeRestrictionLifecycleRepository({this.onSync});

  final Future<void> Function()? onSync;
  int syncCallCount = 0;

  @override
  Future<List<RestrictionLifecycleEventLog>> getEvents({String? modeId, String? sessionId, int limit = 500}) {
    throw UnimplementedError();
  }

  @override
  Future<List<RestrictionSessionLog>> getSessions({String? modeId, int limit = 200}) {
    throw UnimplementedError();
  }

  @override
  Future<void> syncFromPluginQueue({int batchSize = 200}) async {
    syncCallCount += 1;
    await onSync?.call();
  }
}

final class _FakeStreaksRepository implements StreaksRepository {
  _FakeStreaksRepository();
  int refreshCallCount = 0;

  @override
  Future<StreakSnapshot> getGlobalSnapshot({required DateTime nowLocal}) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshAggregates() async {
    refreshCallCount += 1;
  }
}
