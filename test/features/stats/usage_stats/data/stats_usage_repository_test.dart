import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockUsageStatsManager usageStatsManager;
  late StatsUsageRepository repository;

  setUpAll(() {
    registerFallbackValue(<UsageEventType>[]);
  });

  setUp(() {
    usageStatsManager = MockUsageStatsManager();
    repository = StatsUsageRepositoryImpl(usageStatsManager: usageStatsManager);
  });

  group('StatsUsageRepository.getExactDeviceEventSnapshot', () {
    test('clips raw screen-on intervals to the requested window and counts unlocks', () async {
      final window = DateTimeRange(start: DateTime(2026, 4, 27, 10), end: DateTime(2026, 4, 27, 12));

      when(
        () => usageStatsManager.getUsageEvents(
          startDate: window.start,
          endDate: window.end,
          eventTypes: any(named: 'eventTypes'),
        ),
      ).thenAnswer(
        (_) async => <UsageEvent>[
          UsageEvent(
            timestamp: DateTime(2026, 4, 27, 9, 30),
            packageName: 'android',
            eventType: UsageEventType.screenInteractive,
          ),
          UsageEvent(
            timestamp: DateTime(2026, 4, 27, 10, 15),
            packageName: 'android',
            eventType: UsageEventType.keyguardHidden,
          ),
          UsageEvent(
            timestamp: DateTime(2026, 4, 27, 10, 30),
            packageName: 'android',
            eventType: UsageEventType.screenNonInteractive,
          ),
          UsageEvent(
            timestamp: DateTime(2026, 4, 27, 11),
            packageName: 'android',
            eventType: UsageEventType.screenInteractive,
          ),
          UsageEvent(
            timestamp: DateTime(2026, 4, 27, 11, 30),
            packageName: 'android',
            eventType: UsageEventType.keyguardHidden,
          ),
          UsageEvent(
            timestamp: DateTime(2026, 4, 27, 12, 30),
            packageName: 'android',
            eventType: UsageEventType.screenNonInteractive,
          ),
        ],
      );

      final snapshot = await repository.getExactDeviceEventSnapshot(window: window);

      expect(snapshot.screenOnCount, 2);
      expect(snapshot.totalScreenOnTime, const Duration(minutes: 90));
      expect(snapshot.unlockCount, 2);
    });
  });
}
