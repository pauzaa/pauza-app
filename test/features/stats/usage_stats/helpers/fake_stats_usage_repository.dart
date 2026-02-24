import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_engagement_insight.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_usage_insights.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

/// A configurable fake [StatsUsageRepository] for tests.
///
/// Supply [current] / [previous] usage-stat lists for alternating calls,
/// override [deviceInsights], [topEngagement], [heatmap] with custom values,
/// or inject errors via [deviceInsightsError] / [topEngagementError].
///
/// Call counters and last-argument captures are exposed for assertions.
class FakeStatsUsageRepository implements StatsUsageRepository {
  FakeStatsUsageRepository({
    this.current = const <UsageStats>[],
    this.previous = const <UsageStats>[],
    this.deviceInsights,
    this.topEngagement,
    this.heatmap,
    this.deviceInsightsError,
    this.topEngagementError,
  });

  final List<UsageStats> current;
  final List<UsageStats> previous;
  final DeviceUsageInsights? deviceInsights;
  final IList<AppEngagementInsight>? topEngagement;
  final IMap<int, Duration>? heatmap;
  final Object? deviceInsightsError;
  final Object? topEngagementError;

  /// Number of times [getUsageStats] was called.
  var calls = 0;

  /// Number of times [getDeviceUsageInsights] was called.
  var deviceInsightsCalls = 0;

  /// Number of times [getTopAppEngagementInsights] was called.
  var topEngagementCalls = 0;

  /// Number of times [getHourlyScreenTimeHeatmap] was called.
  var heatmapCalls = 0;

  DateTime? lastDeviceInsightsStart;
  DateTime? lastDeviceInsightsEnd;
  DateTime? lastTopEngagementStart;
  DateTime? lastTopEngagementEnd;
  DateTime? lastHeatmapStart;
  DateTime? lastHeatmapEnd;

  @override
  Future<IList<UsageStats>> getUsageStats({
    required DateTime start,
    required DateTime end,
    bool includeIcons = false,
  }) async {
    calls++;
    if (current.isEmpty) {
      return <UsageStats>[_defaultUsage(start: start)].lock;
    }
    return calls.isOdd ? current.lock : previous.lock;
  }

  @override
  Future<UsageStats?> getAppUsageStats({
    required String packageId,
    required DateTime start,
    required DateTime end,
    bool includeIcons = false,
  }) async {
    return null;
  }

  @override
  Future<IList<UsageEvent>> getUsageEvents({
    required DateTime start,
    required DateTime end,
    IList<UsageEventType>? eventTypes,
  }) async {
    return const IListConst<UsageEvent>(<UsageEvent>[]);
  }

  @override
  Future<IList<DeviceEventStats>> getEventStats({
    required DateTime start,
    required DateTime end,
    UsageStatsInterval interval = UsageStatsInterval.daily,
  }) async {
    return const IListConst<DeviceEventStats>(<DeviceEventStats>[]);
  }

  @override
  Future<bool> isAppInactive({required String packageId}) async {
    return false;
  }

  @override
  Future<AppStandbyBucket> getAppStandbyBucket() async {
    return AppStandbyBucket.active;
  }

  @override
  Future<DeviceUsageInsights> getDeviceUsageInsights({required DateTime start, required DateTime end}) async {
    deviceInsightsCalls++;
    lastDeviceInsightsStart = start;
    lastDeviceInsightsEnd = end;
    if (deviceInsightsError != null) {
      throw deviceInsightsError!;
    }
    return deviceInsights ?? _defaultDeviceInsights;
  }

  @override
  Future<IList<AppEngagementInsight>> getTopAppEngagementInsights({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  }) async {
    topEngagementCalls++;
    lastTopEngagementStart = start;
    lastTopEngagementEnd = end;
    if (topEngagementError != null) {
      throw topEngagementError!;
    }
    return topEngagement ?? _defaultTopEngagement;
  }

  @override
  Future<IMap<int, Duration>> getHourlyScreenTimeHeatmap({required DateTime start, required DateTime end}) async {
    heatmapCalls++;
    lastHeatmapStart = start;
    lastHeatmapEnd = end;
    return heatmap ?? _defaultHeatmap;
  }
}

UsageStats _defaultUsage({required DateTime start}) {
  return UsageStats(
    appInfo: const AndroidAppInfo(packageId: AppIdentifier.android('demo.app'), name: 'demo.app', category: 'Social'),
    totalDuration: const Duration(minutes: 30),
    totalLaunchCount: 1,
    bucketStart: start.dayStart,
    bucketEnd: start.dayEnd,
    lastTimeUsed: start,
  );
}

const _defaultDeviceInsights = DeviceUsageInsights(
  unlockCount: 10,
  lockCount: 10,
  pickupCount: 20,
  screenOnDuration: Duration(minutes: 200),
  unlockedDuration: Duration(minutes: 180),
  screenOnSessionAverage: Duration(minutes: 10),
  unlocksPerDayAverage: 2,
  firstUnlockAt: null,
  lastUnlockAt: null,
  source: DeviceUsageInsightsSource.eventStats,
);

final IList<AppEngagementInsight> _defaultTopEngagement = <AppEngagementInsight>[
  const AppEngagementInsight(
    appInfo: AndroidAppInfo(packageId: AppIdentifier.android('social.app'), name: 'social.app'),
    totalDuration: Duration(minutes: 100),
    totalLaunchCount: 30,
    averageSessionDuration: Duration(minutes: 3),
    launchesPerHour: 1.4,
    engagementScore: 0.91,
  ),
].lock;

final IMap<int, Duration> _defaultHeatmap = IMap<int, Duration>.fromEntries(
  List.generate(24, (index) => MapEntry(index, index == 9 ? const Duration(minutes: 90) : Duration.zero)),
);
