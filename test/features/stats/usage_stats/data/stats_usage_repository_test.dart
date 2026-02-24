import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_usage_insights.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('StatsUsageRepositoryImpl', () {
    test('getUsageStats deduplicates by app identity and keeps deterministic order', () async {
      final platform = _FakeUsageStatsPlatform()
        ..usageStatsResult = <UsageStats>[
          _usage(packageId: 'a', minutes: 10, launches: 1, lastUsed: DateTime(2026, 2, 1, 10)),
          _usage(packageId: 'b', minutes: 30, launches: 5, lastUsed: DateTime(2026, 2, 1, 9)),
          _usage(packageId: 'a', minutes: 20, launches: 3, lastUsed: DateTime(2026, 2, 1, 12)),
          _usage(packageId: 'zero', minutes: 0, launches: 7),
        ];
      final repository = _repository(platform);

      final result = await repository.getUsageStats(start: DateTime(2026, 2), end: DateTime(2026, 2, 2));

      expect(platform.lastGetUsageStatsIncludeIcons, isFalse);
      expect(result.map((e) => e.appInfo.identifier.raw).toList(), <String>['b', 'a']);
      expect(result.last.totalDuration, const Duration(minutes: 30));
      expect(result.last.totalLaunchCount, 4);
      expect(result.last.lastTimeUsed, DateTime(2026, 2, 1, 12));
    });

    test('getDailyUsageDurations performs explicit day-level aggregation', () async {
      final platform = _FakeUsageStatsPlatform()
        ..usageStatsByRangeStart = <int, List<UsageStats>>{
          DateTime(2026, 2).millisecondsSinceEpoch: <UsageStats>[
            _usage(packageId: 'a', minutes: 30, launches: 2),
          ],
          DateTime(2026, 2, 2).millisecondsSinceEpoch: <UsageStats>[
            _usage(packageId: 'a', minutes: 10, launches: 1),
            _usage(packageId: 'b', minutes: 20, launches: 2),
          ],
        };
      final repository = _repository(platform);

      final daily = await repository.getDailyUsageDurations(start: DateTime(2026, 2), end: DateTime(2026, 2, 2, 23));

      expect(daily.length, 2);
      expect(daily[DateTime(2026, 2)], const Duration(minutes: 30));
      expect(daily[DateTime(2026, 2, 2)], const Duration(minutes: 30));
      expect(platform.getUsageStatsCallCount, 2);
    });

    test('direct passthrough APIs delegate to UsageStatsManager', () async {
      final platform = _FakeUsageStatsPlatform()
        ..singleUsageResult = _usage(packageId: 'single', minutes: 5, launches: 2)
        ..usageEventsResult = <UsageEvent>[_event(type: UsageEventType.keyguardHidden, at: DateTime(2026, 2, 1, 9))]
        ..eventStatsResult = <DeviceEventStats>[
          _eventStat(type: UsageEventType.keyguardHidden, count: 1, totalMinutes: 5),
        ]
        ..isInactiveResult = true
        ..standbyBucketResult = AppStandbyBucket.frequent;
      final repository = _repository(platform);

      final appUsage = await repository.getAppUsageStats(
        packageId: 'single',
        start: DateTime(2026, 2),
        end: DateTime(2026, 2, 2),
      );
      final events = await repository.getUsageEvents(start: DateTime(2026, 2), end: DateTime(2026, 2, 2));
      final eventStats = await repository.getEventStats(start: DateTime(2026, 2), end: DateTime(2026, 2, 2));
      final inactive = await repository.isAppInactive(packageId: 'pkg');
      final bucket = await repository.getAppStandbyBucket();

      expect(appUsage?.appInfo.name, 'single');
      expect(events.length, 1);
      expect(eventStats.length, 1);
      expect(inactive, isTrue);
      expect(bucket, AppStandbyBucket.frequent);
    });

    test('getDeviceUsageInsights uses event stats path when available', () async {
      final platform = _FakeUsageStatsPlatform()
        ..eventStatsResult = <DeviceEventStats>[
          _eventStat(type: UsageEventType.keyguardHidden, count: 6, totalMinutes: 90),
          _eventStat(type: UsageEventType.keyguardShown, count: 6, totalMinutes: 80),
          _eventStat(type: UsageEventType.screenInteractive, count: 8, totalMinutes: 180),
        ]
        ..usageEventsResult = <UsageEvent>[
          _event(type: UsageEventType.keyguardHidden, at: DateTime(2026, 2, 1, 8)),
          _event(type: UsageEventType.keyguardHidden, at: DateTime(2026, 2, 2, 20)),
        ];
      final repository = _repository(platform);

      final insights = await repository.getDeviceUsageInsights(start: DateTime(2026, 2), end: DateTime(2026, 2, 3));

      expect(insights.source, DeviceUsageInsightsSource.eventStats);
      expect(insights.unlockCount, 6);
      expect(insights.pickupCount, 8);
      expect(insights.screenOnDuration, const Duration(minutes: 180));
      expect(insights.unlockedDuration, const Duration(minutes: 90));
      expect(insights.screenOnSessionAverage, const Duration(minutes: 22, seconds: 30));
      expect(insights.firstUnlockAt, DateTime(2026, 2));
      expect(insights.lastUnlockAt, DateTime(2026, 2, 2));
    });

    test('getDeviceUsageInsights fast-path does NOT call getUsageEvents', () async {
      final platform = _FakeUsageStatsPlatform()
        ..eventStatsResult = <DeviceEventStats>[
          _eventStat(type: UsageEventType.keyguardHidden, count: 3, totalMinutes: 30),
        ];
      final repository = _repository(platform);

      await repository.getDeviceUsageInsights(start: DateTime(2026, 2), end: DateTime(2026, 2, 2));

      expect(platform.getUsageEventsCallCount, 0);
    });

    test('getDeviceUsageInsights falls back to usage events on unsupported event stats', () async {
      final platform = _FakeUsageStatsPlatform()
        ..throwUnsupportedOnEventStats = true
        ..usageEventsResult = <UsageEvent>[
          _event(type: UsageEventType.keyguardHidden, at: DateTime(2026, 2, 1, 8)),
          _event(type: UsageEventType.keyguardShown, at: DateTime(2026, 2, 1, 8, 40)),
          _event(type: UsageEventType.screenInteractive, at: DateTime(2026, 2, 1, 9)),
          _event(type: UsageEventType.screenNonInteractive, at: DateTime(2026, 2, 1, 9, 50)),
        ];
      final repository = _repository(platform);

      final insights = await repository.getDeviceUsageInsights(start: DateTime(2026, 2), end: DateTime(2026, 2, 2));

      expect(insights.source, DeviceUsageInsightsSource.usageEventsFallback);
      expect(insights.unlockCount, 1);
      expect(insights.lockCount, 1);
      expect(insights.pickupCount, 1);
      expect(insights.unlockedDuration, const Duration(minutes: 40));
      expect(insights.screenOnDuration, const Duration(minutes: 50));
    });

    test('getDeviceUsageInsights returns null screenOnSessionAverage when pickupCount is zero', () async {
      final platform = _FakeUsageStatsPlatform()
        ..eventStatsResult = <DeviceEventStats>[
          _eventStat(type: UsageEventType.keyguardHidden, count: 2, totalMinutes: 10),
        ];
      final repository = _repository(platform);

      final insights = await repository.getDeviceUsageInsights(start: DateTime(2026, 2), end: DateTime(2026, 2, 2));

      expect(insights.pickupCount, 0);
      expect(insights.screenOnSessionAverage, isNull);
    });

    test('_sumDurationBetweenEventPairs handles consecutive start events without losing time', () async {
      final platform = _FakeUsageStatsPlatform()
        ..throwUnsupportedOnEventStats = true
        ..usageEventsResult = <UsageEvent>[
          _event(type: UsageEventType.screenInteractive, at: DateTime(2026, 2, 1, 9)),
          _event(type: UsageEventType.screenInteractive, at: DateTime(2026, 2, 1, 10)),
          _event(type: UsageEventType.screenNonInteractive, at: DateTime(2026, 2, 1, 10, 30)),
        ];
      final repository = _repository(platform);

      final insights = await repository.getDeviceUsageInsights(start: DateTime(2026, 2), end: DateTime(2026, 2, 2));

      expect(insights.screenOnDuration, const Duration(minutes: 90));
    });

    test('getTopAppEngagementInsights uses consolidated app usage for ranking', () async {
      final platform = _FakeUsageStatsPlatform()
        ..usageStatsResult = <UsageStats>[
          _usage(packageId: 'a', minutes: 25, launches: 2),
          _usage(packageId: 'a', minutes: 25, launches: 2),
          _usage(packageId: 'b', minutes: 30, launches: 3),
        ];
      final repository = _repository(platform);

      final insights = await repository.getTopAppEngagementInsights(
        start: DateTime(2026, 2),
        end: DateTime(2026, 2, 2),
        limit: 2,
      );

      expect(insights.length, 2);
      expect(insights.first.appInfo.name, 'a');
      expect(insights.first.totalDuration, const Duration(minutes: 50));
      expect(insights.first.totalLaunchCount, 4);
    });

    test('getHourlyScreenTimeHeatmap splits usage intervals across hourly buckets', () async {
      final platform = _FakeUsageStatsPlatform()
        ..usageEventsResult = <UsageEvent>[
          _appEvent(type: UsageEventType.activityResumed, at: DateTime(2026, 2, 1, 9, 50), packageName: 'a'),
          _appEvent(type: UsageEventType.activityPaused, at: DateTime(2026, 2, 1, 10, 10), packageName: 'a'),
        ];
      final repository = _repository(platform);

      final heatmap = await repository.getHourlyScreenTimeHeatmap(
        start: DateTime(2026, 2, 1, 9),
        end: DateTime(2026, 2, 1, 11),
      );

      expect(heatmap.length, 24);
      expect(heatmap[9], const Duration(minutes: 10));
      expect(heatmap[10], const Duration(minutes: 10));
    });

    test('getHourlyScreenTimeHeatmap does not double count interleaved app events', () async {
      final platform = _FakeUsageStatsPlatform()
        ..usageEventsResult = <UsageEvent>[
          _appEvent(type: UsageEventType.activityResumed, at: DateTime(2026, 2, 1, 9), packageName: 'a'),
          _appEvent(type: UsageEventType.activityResumed, at: DateTime(2026, 2, 1, 9, 10), packageName: 'b'),
          _appEvent(type: UsageEventType.activityPaused, at: DateTime(2026, 2, 1, 9, 20), packageName: 'b'),
        ];
      final repository = _repository(platform);

      final heatmap = await repository.getHourlyScreenTimeHeatmap(
        start: DateTime(2026, 2, 1, 9),
        end: DateTime(2026, 2, 1, 10),
      );

      expect(heatmap[9], const Duration(minutes: 20));
    });
  });
}

StatsUsageRepositoryImpl _repository(_FakeUsageStatsPlatform platform) {
  return StatsUsageRepositoryImpl(usageStatsManager: platform);
}

class _FakeUsageStatsPlatform extends UsageStatsManager {
  List<UsageStats> usageStatsResult = <UsageStats>[];
  Map<int, List<UsageStats>> usageStatsByRangeStart = <int, List<UsageStats>>{};
  UsageStats? singleUsageResult;
  List<UsageEvent> usageEventsResult = <UsageEvent>[];
  List<DeviceEventStats> eventStatsResult = <DeviceEventStats>[];
  bool isInactiveResult = false;
  AppStandbyBucket standbyBucketResult = AppStandbyBucket.active;
  bool throwUnsupportedOnEventStats = false;
  int getUsageEventsCallCount = 0;
  int getUsageStatsCallCount = 0;

  bool? lastGetUsageStatsIncludeIcons;

  @override
  Future<List<UsageStats>> getUsageStats({
    required DateTime startDate,
    required DateTime endDate,
    bool includeIcons = true,
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    getUsageStatsCallCount++;
    lastGetUsageStatsIncludeIcons = includeIcons;

    final byStart = usageStatsByRangeStart[startDate.millisecondsSinceEpoch];
    if (byStart != null) {
      return byStart;
    }

    return usageStatsResult;
  }

  @override
  Future<UsageStats?> getAppUsageStats({
    required String packageId,
    required DateTime startDate,
    required DateTime endDate,
    bool includeIcons = true,
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return singleUsageResult;
  }

  @override
  Future<List<UsageEvent>> getUsageEvents({
    required DateTime startDate,
    required DateTime endDate,
    List<UsageEventType>? eventTypes,
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    getUsageEventsCallCount++;
    if (eventTypes == null) {
      return usageEventsResult;
    }
    return usageEventsResult.where((event) => eventTypes.contains(event.eventType)).toList(growable: false);
  }

  @override
  Future<List<DeviceEventStats>> getEventStats({
    required DateTime startDate,
    required DateTime endDate,
    UsageStatsInterval intervalType = UsageStatsInterval.best,
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (throwUnsupportedOnEventStats) {
      throw const PauzaUnsupportedError(message: 'unsupported', rawCode: 'UNSUPPORTED');
    }
    return eventStatsResult;
  }

  @override
  Future<bool> isAppInactive({
    required String packageId,
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return isInactiveResult;
  }

  @override
  Future<AppStandbyBucket> getAppStandbyBucket({
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return standbyBucketResult;
  }
}

UsageStats _usage({required String packageId, required int minutes, required int launches, DateTime? lastUsed}) {
  return UsageStats(
    appInfo: AndroidAppInfo(packageId: AppIdentifier.android(packageId), name: packageId),
    totalDuration: Duration(minutes: minutes),
    totalLaunchCount: launches,
    lastTimeUsed: lastUsed ?? DateTime(2026, 2, 1, 12),
  );
}

UsageEvent _event({required UsageEventType type, required DateTime at}) {
  return UsageEvent(timestamp: at, packageName: 'android', eventType: type);
}

UsageEvent _appEvent({required UsageEventType type, required DateTime at, required String packageName}) {
  return UsageEvent(timestamp: at, packageName: packageName, eventType: type);
}

DeviceEventStats _eventStat({required UsageEventType type, required int count, required int totalMinutes}) {
  return DeviceEventStats(
    eventType: type,
    count: count,
    totalTime: Duration(minutes: totalMinutes),
    firstTimestamp: DateTime(2026, 2),
    lastTimestamp: DateTime(2026, 2, 2),
    lastEventTime: DateTime(2026, 2, 2),
  );
}
