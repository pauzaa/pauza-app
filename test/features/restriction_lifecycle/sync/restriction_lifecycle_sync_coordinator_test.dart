import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_lifecycle_event_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_session_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/restriction_lifecycle_sync_coordinator.dart';

void main() {
  group('RestrictionLifecycleSyncCoordinator', () {
    test('syncNow calls syncFromPluginQueue', () async {
      final lifecycleRepository = FakeRestrictionLifecycleRepository();
      final coordinator = RestrictionLifecycleSyncCoordinator(repository: lifecycleRepository);

      await coordinator.syncNow();

      expect(lifecycleRepository.syncCallCount, 1);
    });

    test('syncNow deduplicates concurrent calls', () async {
      final syncCompleter = Completer<void>();
      final lifecycleRepository = FakeRestrictionLifecycleRepository(onSyncFromPluginQueue: () => syncCompleter.future);
      final coordinator = RestrictionLifecycleSyncCoordinator(repository: lifecycleRepository);

      final first = coordinator.syncNow();
      final second = coordinator.syncNow();

      expect(lifecycleRepository.syncCallCount, 1);

      syncCompleter.complete();
      await Future.wait([first, second]);

      expect(lifecycleRepository.syncCallCount, 1);
    });

    test('syncNow does not throw when sync fails', () async {
      final lifecycleRepository = FakeRestrictionLifecycleRepository(
        onSyncFromPluginQueue: () async {
          throw StateError('sync_failed');
        },
      );
      final coordinator = RestrictionLifecycleSyncCoordinator(repository: lifecycleRepository);

      // Should not throw — errors are logged internally.
      await coordinator.syncNow();

      expect(lifecycleRepository.syncCallCount, 1);
    });

    test('syncNow allows new call after previous completes', () async {
      final lifecycleRepository = FakeRestrictionLifecycleRepository();
      final coordinator = RestrictionLifecycleSyncCoordinator(repository: lifecycleRepository);

      await coordinator.syncNow();
      await coordinator.syncNow();

      expect(lifecycleRepository.syncCallCount, 2);
    });
  });
}

final class FakeRestrictionLifecycleRepository implements RestrictionLifecycleRepository {
  FakeRestrictionLifecycleRepository({this.onSyncFromPluginQueue});

  final Future<void> Function()? onSyncFromPluginQueue;
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
    await onSyncFromPluginQueue?.call();
  }
}
