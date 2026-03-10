import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_lifecycle_event_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_session_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/restriction_lifecycle_sync_coordinator.dart';
import 'package:pauza/src/features/streaks/common/model/streak_snapshot.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';

void main() {
  group('RestrictionLifecycleSyncCoordinator', () {
    test('syncNow calls sync then refresh in order', () async {
      final callOrder = <String>[];
      final lifecycleRepository = FakeRestrictionLifecycleRepository(
        onSyncFromPluginQueue: () async {
          callOrder.add('sync');
        },
      );
      final streaksRepository = FakeStreaksRepository(
        onRefreshAggregates: () async {
          callOrder.add('refresh');
        },
      );
      final coordinator = RestrictionLifecycleSyncCoordinator(
        repository: lifecycleRepository,
        streaksRepository: streaksRepository,
      );

      await coordinator.syncNow();

      expect(callOrder, ['sync', 'refresh']);
      expect(lifecycleRepository.syncCallCount, 1);
      expect(streaksRepository.refreshCallCount, 1);
    });

    test('syncNow deduplicates concurrent calls and performs one sync and one refresh', () async {
      final syncCompleter = Completer<void>();
      final lifecycleRepository = FakeRestrictionLifecycleRepository(
        onSyncFromPluginQueue: () => syncCompleter.future,
      );
      final streaksRepository = FakeStreaksRepository();
      final coordinator = RestrictionLifecycleSyncCoordinator(
        repository: lifecycleRepository,
        streaksRepository: streaksRepository,
      );

      final first = coordinator.syncNow();
      final second = coordinator.syncNow();

      expect(lifecycleRepository.syncCallCount, 1);
      expect(streaksRepository.refreshCallCount, 0);

      syncCompleter.complete();
      await Future.wait([first, second]);

      expect(lifecycleRepository.syncCallCount, 1);
      expect(streaksRepository.refreshCallCount, 1);
    });

    test('refresh is not called when sync throws', () async {
      final lifecycleRepository = FakeRestrictionLifecycleRepository(
        onSyncFromPluginQueue: () async {
          throw StateError('sync_failed');
        },
      );
      final streaksRepository = FakeStreaksRepository();
      final coordinator = RestrictionLifecycleSyncCoordinator(
        repository: lifecycleRepository,
        streaksRepository: streaksRepository,
      );

      await expectLater(coordinator.syncNow(), throwsA(isA<StateError>()));

      expect(lifecycleRepository.syncCallCount, 1);
      expect(streaksRepository.refreshCallCount, 0);
    });

    test('syncNow propagates refresh error after successful sync', () async {
      final lifecycleRepository = FakeRestrictionLifecycleRepository();
      final streaksRepository = FakeStreaksRepository(
        onRefreshAggregates: () async {
          throw StateError('refresh_failed');
        },
      );
      final coordinator = RestrictionLifecycleSyncCoordinator(
        repository: lifecycleRepository,
        streaksRepository: streaksRepository,
      );

      await expectLater(coordinator.syncNow(), throwsA(isA<StateError>()));

      expect(lifecycleRepository.syncCallCount, 1);
      expect(streaksRepository.refreshCallCount, 1);
    });

    testWidgets('didChangeAppLifecycleState(resumed) triggers syncNow once', (tester) async {
      final syncCompleter = Completer<void>();
      final lifecycleRepository = FakeRestrictionLifecycleRepository(
        onSyncFromPluginQueue: () => syncCompleter.future,
      );
      final streaksRepository = FakeStreaksRepository();
      final coordinator = RestrictionLifecycleSyncCoordinator(
        repository: lifecycleRepository,
        streaksRepository: streaksRepository,
      );

      coordinator.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();

      expect(lifecycleRepository.syncCallCount, 0);
      expect(streaksRepository.refreshCallCount, 0);

      coordinator.didChangeAppLifecycleState(AppLifecycleState.resumed);
      coordinator.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();

      expect(lifecycleRepository.syncCallCount, 1);
      expect(streaksRepository.refreshCallCount, 0);

      syncCompleter.complete();
      await tester.pump();

      expect(streaksRepository.refreshCallCount, 1);
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

final class FakeStreaksRepository implements StreaksRepository {
  FakeStreaksRepository({this.onRefreshAggregates});

  final Future<void> Function()? onRefreshAggregates;
  int refreshCallCount = 0;

  @override
  Future<StreakSnapshot> getGlobalSnapshot({required DateTime nowLocal}) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshAggregates() async {
    refreshCallCount += 1;
    await onRefreshAggregates?.call();
  }
}
