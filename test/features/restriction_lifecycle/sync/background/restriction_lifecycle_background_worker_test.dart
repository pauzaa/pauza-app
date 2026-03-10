import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_worker.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('RestrictionLifecycleBackgroundWorker', () {
    late MockRestrictionLifecycleBackgroundDependenciesFactory factory;
    late MockRestrictionLifecycleBackgroundDependencies dependencies;
    late MockAuthSessionStorage authSessionStorage;
    late MockRestrictionLifecycleRepository restrictionLifecycleRepository;
    late MockStreaksRepository streaksRepository;

    setUp(() {
      factory = MockRestrictionLifecycleBackgroundDependenciesFactory();
      dependencies = MockRestrictionLifecycleBackgroundDependencies();
      authSessionStorage = MockAuthSessionStorage();
      restrictionLifecycleRepository = MockRestrictionLifecycleRepository();
      streaksRepository = MockStreaksRepository();

      when(() => dependencies.authSessionStorage).thenReturn(authSessionStorage);
      when(() => dependencies.restrictionLifecycleRepository).thenReturn(restrictionLifecycleRepository);
      when(() => dependencies.streaksRepository).thenReturn(streaksRepository);
      when(() => dependencies.close()).thenAnswer((_) async {});
      when(() => factory.create()).thenAnswer((_) async => dependencies);
    });

    test('returns success and skips sync when session is not authenticated', () async {
      when(() => authSessionStorage.readSession()).thenAnswer((_) async => const Session.empty());

      final worker = RestrictionLifecycleBackgroundWorker(dependenciesFactory: factory);

      final result = await worker.run();

      expect(result, RestrictionLifecycleBackgroundTaskResult.success);
      verifyNever(() => restrictionLifecycleRepository.syncFromPluginQueue());
      verifyNever(() => streaksRepository.refreshAggregates());
      verify(() => dependencies.close()).called(1);
    });

    test('returns success when sync and refresh succeed', () async {
      when(() => authSessionStorage.readSession()).thenAnswer((_) async => makeSession());
      when(() => restrictionLifecycleRepository.syncFromPluginQueue()).thenAnswer((_) async {});
      when(() => streaksRepository.refreshAggregates()).thenAnswer((_) async {});

      final worker = RestrictionLifecycleBackgroundWorker(dependenciesFactory: factory);

      final result = await worker.run();

      expect(result, RestrictionLifecycleBackgroundTaskResult.success);
      verify(() => restrictionLifecycleRepository.syncFromPluginQueue()).called(1);
      verify(() => streaksRepository.refreshAggregates()).called(1);
      verify(() => dependencies.close()).called(1);
    });

    test('returns retry when sync fails after authenticated setup', () async {
      when(() => authSessionStorage.readSession()).thenAnswer((_) async => makeSession());
      when(() => restrictionLifecycleRepository.syncFromPluginQueue()).thenThrow(StateError('sync_failed'));

      final worker = RestrictionLifecycleBackgroundWorker(dependenciesFactory: factory);

      final result = await worker.run();

      expect(result, RestrictionLifecycleBackgroundTaskResult.retry);
      verify(() => restrictionLifecycleRepository.syncFromPluginQueue()).called(1);
      verifyNever(() => streaksRepository.refreshAggregates());
      verify(() => dependencies.close()).called(1);
    });

    test('returns success when dependencies setup fails', () async {
      when(() => factory.create()).thenThrow(StateError('setup_failed'));

      final worker = RestrictionLifecycleBackgroundWorker(dependenciesFactory: factory);

      final result = await worker.run();

      expect(result, RestrictionLifecycleBackgroundTaskResult.success);
    });
  });
}
