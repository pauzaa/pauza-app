import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_scheduler.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_worker.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  group('WorkmanagerRestrictionLifecycleBackgroundScheduler', () {
    test('initializes workmanager and registers daily periodic task', () async {
      final workmanagerClient = _FakeWorkmanagerClient();
      final scheduler = WorkmanagerRestrictionLifecycleBackgroundScheduler(
        workmanagerClient: workmanagerClient,
        nowLocal: () => DateTime(2026, 2, 23, 10),
      );

      await scheduler.initializeAndScheduleDailySync();

      expect(workmanagerClient.initializeCallCount, 1);
      expect(workmanagerClient.lastUniqueName, restrictionLifecycleBackgroundTaskUniqueName);
      expect(workmanagerClient.lastTaskName, restrictionLifecycleBackgroundTaskIdentifier);
      expect(workmanagerClient.lastFrequency, const Duration(hours: 24));
      expect(workmanagerClient.lastExistingWorkPolicy, ExistingPeriodicWorkPolicy.replace);
      expect(workmanagerClient.lastBackoffPolicy, BackoffPolicy.linear);
      expect(workmanagerClient.lastBackoffPolicyDelay, const Duration(minutes: 30));
      expect(workmanagerClient.lastInitialDelay, const Duration(hours: 14));
    });

    test('computes initial delay as one full day when now is midnight', () async {
      final workmanagerClient = _FakeWorkmanagerClient();
      final scheduler = WorkmanagerRestrictionLifecycleBackgroundScheduler(
        workmanagerClient: workmanagerClient,
        nowLocal: () => DateTime(2026, 2, 23),
      );

      await scheduler.initializeAndScheduleDailySync();

      expect(workmanagerClient.lastInitialDelay, const Duration(hours: 24));
    });

    test('computes short initial delay when near midnight', () async {
      final workmanagerClient = _FakeWorkmanagerClient();
      final scheduler = WorkmanagerRestrictionLifecycleBackgroundScheduler(
        workmanagerClient: workmanagerClient,
        nowLocal: () => DateTime(2026, 2, 23, 23, 59, 30),
      );

      await scheduler.initializeAndScheduleDailySync();

      expect(workmanagerClient.lastInitialDelay, const Duration(seconds: 30));
    });
  });
}

final class _FakeWorkmanagerClient implements WorkmanagerClient {
  int initializeCallCount = 0;
  int registerPeriodicTaskCallCount = 0;

  String? lastUniqueName;
  String? lastTaskName;
  Duration? lastFrequency;
  Duration? lastInitialDelay;
  ExistingPeriodicWorkPolicy? lastExistingWorkPolicy;
  BackoffPolicy? lastBackoffPolicy;
  Duration? lastBackoffPolicyDelay;

  @override
  Future<void> initialize(Function callbackDispatcher) async {
    initializeCallCount += 1;
  }

  @override
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    required Duration frequency,
    Duration? initialDelay,
    ExistingPeriodicWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
  }) async {
    registerPeriodicTaskCallCount += 1;
    lastUniqueName = uniqueName;
    lastTaskName = taskName;
    lastFrequency = frequency;
    lastInitialDelay = initialDelay;
    lastExistingWorkPolicy = existingWorkPolicy;
    lastBackoffPolicy = backoffPolicy;
    lastBackoffPolicyDelay = backoffPolicyDelay;
  }
}
