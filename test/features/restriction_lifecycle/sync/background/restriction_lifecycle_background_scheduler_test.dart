import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_scheduler.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_worker.dart';
import 'package:workmanager/workmanager.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerTestFallbackValues);

  group('WorkmanagerRestrictionLifecycleBackgroundScheduler', () {
    late MockWorkmanagerClient workmanagerClient;

    setUp(() {
      workmanagerClient = MockWorkmanagerClient();
      when(() => workmanagerClient.initialize(any())).thenAnswer((_) async {});
      when(
        () => workmanagerClient.registerPeriodicTask(
          any(),
          any(),
          frequency: any(named: 'frequency'),
          initialDelay: any(named: 'initialDelay'),
          existingWorkPolicy: any(named: 'existingWorkPolicy'),
          backoffPolicy: any(named: 'backoffPolicy'),
          backoffPolicyDelay: any(named: 'backoffPolicyDelay'),
        ),
      ).thenAnswer((_) async {});
    });

    test('initializes workmanager and registers daily periodic task', () async {
      final scheduler = WorkmanagerRestrictionLifecycleBackgroundScheduler(
        workmanagerClient: workmanagerClient,
        nowLocal: () => DateTime(2026, 2, 23, 10),
      );

      await scheduler.initializeAndScheduleDailySync();

      verify(() => workmanagerClient.initialize(any())).called(1);
      verify(
        () => workmanagerClient.registerPeriodicTask(
          restrictionLifecycleBackgroundTaskUniqueName,
          restrictionLifecycleBackgroundTaskIdentifier,
          frequency: const Duration(hours: 24),
          initialDelay: const Duration(hours: 14),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
          backoffPolicy: BackoffPolicy.linear,
          backoffPolicyDelay: const Duration(minutes: 30),
        ),
      ).called(1);
    });

    test('computes initial delay as one full day when now is midnight', () async {
      final scheduler = WorkmanagerRestrictionLifecycleBackgroundScheduler(
        workmanagerClient: workmanagerClient,
        nowLocal: () => DateTime(2026, 2, 23),
      );

      await scheduler.initializeAndScheduleDailySync();

      verify(
        () => workmanagerClient.registerPeriodicTask(
          any(),
          any(),
          frequency: any(named: 'frequency'),
          initialDelay: const Duration(hours: 24),
          existingWorkPolicy: any(named: 'existingWorkPolicy'),
          backoffPolicy: any(named: 'backoffPolicy'),
          backoffPolicyDelay: any(named: 'backoffPolicyDelay'),
        ),
      ).called(1);
    });

    test('computes short initial delay when near midnight', () async {
      final scheduler = WorkmanagerRestrictionLifecycleBackgroundScheduler(
        workmanagerClient: workmanagerClient,
        nowLocal: () => DateTime(2026, 2, 23, 23, 59, 30),
      );

      await scheduler.initializeAndScheduleDailySync();

      verify(
        () => workmanagerClient.registerPeriodicTask(
          any(),
          any(),
          frequency: any(named: 'frequency'),
          initialDelay: const Duration(seconds: 30),
          existingWorkPolicy: any(named: 'existingWorkPolicy'),
          backoffPolicy: any(named: 'backoffPolicy'),
          backoffPolicyDelay: any(named: 'backoffPolicyDelay'),
        ),
      ).called(1);
    });
  });
}
