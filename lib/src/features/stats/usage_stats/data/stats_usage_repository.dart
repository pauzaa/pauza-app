import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/model/local_day_key.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_detail.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_entry.dart';
import 'package:pauza/src/features/stats/usage_stats/model/category_usage_bucket.dart';
import 'package:pauza/src/features/stats/usage_stats/model/daily_usage_point.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_event_snapshot.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_stats_snapshot.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

abstract interface class StatsUsageRepository {
  /// Returns an aggregated usage snapshot for the given [window],
  /// including per-app breakdown, per-category breakdown and KPIs.
  Future<UsageStatsSnapshot> getUsageSnapshot({required DateTimeRange window});

  /// Returns per-day usage data points for trend charting.
  ///
  /// Each day in the [window] produces one [DailyUsagePoint].
  /// Icons are not fetched for performance.
  Future<IList<DailyUsagePoint>> getDailyUsageTrend({required DateTimeRange window});

  /// Returns detailed usage data for a single app identified by [packageId],
  /// including a per-day trend and current inactive status.
  ///
  /// [appInfo] is provided by the caller (from the [AppUsageEntry]) so we
  /// don't need to re-fetch metadata when the app has zero usage in [window].
  Future<AppUsageDetail> getAppDetail({
    required AndroidAppInfo appInfo,
    required String packageId,
    required DateTimeRange window,
  });

  /// Returns device-level event statistics (screen-on count, unlock count).
  ///
  /// Requires Android 9+ (API 28+). On lower API levels the plugin throws
  /// [PauzaUnsupportedError].
  Future<DeviceEventSnapshot> getDeviceEventSnapshot({required DateTimeRange window, UsageStatsInterval intervalType});

  /// Returns device-level event statistics computed from raw usage events clipped
  /// to the exact requested [window].
  Future<DeviceEventSnapshot> getExactDeviceEventSnapshot({required DateTimeRange window});
}

final class StatsUsageRepositoryImpl implements StatsUsageRepository {
  const StatsUsageRepositoryImpl({required UsageStatsManager usageStatsManager})
    : _usageStatsManager = usageStatsManager;

  final UsageStatsManager _usageStatsManager;

  // ---------------------------------------------------------------------------
  // getUsageSnapshot
  // ---------------------------------------------------------------------------

  @override
  Future<UsageStatsSnapshot> getUsageSnapshot({required DateTimeRange window}) async {
    final statsList = await _usageStatsManager.getUsageStats(
      startDate: window.start.dayStart,
      endDate: window.end.dayEnd,
    );

    final totalMs = statsList.fold<int>(0, (sum, s) => sum + s.totalDuration.inMilliseconds);
    final totalScreenTime = Duration(milliseconds: totalMs);
    final totalLaunchCount = statsList.fold<int>(0, (sum, s) => sum + s.totalLaunchCount);

    // Sort descending by duration for the per-app list.
    final sorted = List<UsageStats>.of(statsList)..sort((a, b) => b.totalDuration.compareTo(a.totalDuration));

    final appUsageEntries = sorted.map((s) {
      return AppUsageEntry(
        appInfo: s.appInfo,
        totalDuration: s.totalDuration,
        launchCount: s.totalLaunchCount,
        shareOfTotal: totalMs > 0 ? s.totalDuration.inMilliseconds / totalMs : 0,
        lastTimeUsed: s.lastTimeUsed,
      );
    }).toIList();

    final categoryBreakdown = _buildCategoryBreakdown(statsList: sorted, totalMs: totalMs);

    final windowDays = _dayCount(window);
    final averageDailyScreenTime = windowDays > 0 ? Duration(milliseconds: totalMs ~/ windowDays) : Duration.zero;

    return UsageStatsSnapshot(
      totalScreenTime: totalScreenTime,
      totalLaunchCount: totalLaunchCount,
      appUsageEntries: appUsageEntries,
      categoryBreakdown: categoryBreakdown,
      averageDailyScreenTime: averageDailyScreenTime,
    );
  }

  // ---------------------------------------------------------------------------
  // getDailyUsageTrend
  // ---------------------------------------------------------------------------

  @override
  Future<IList<DailyUsagePoint>> getDailyUsageTrend({required DateTimeRange window}) async {
    final days = _generateDays(window);

    final results = await Future.wait(
      days.map(
        (day) => _usageStatsManager.getUsageStats(startDate: day.dayStart, endDate: day.dayEnd, includeIcons: false),
      ),
    );

    final points = <DailyUsagePoint>[];
    for (var i = 0; i < days.length; i++) {
      final statsList = results[i];
      final totalMs = statsList.fold<int>(0, (sum, s) => sum + s.totalDuration.inMilliseconds);
      final totalLaunches = statsList.fold<int>(0, (sum, s) => sum + s.totalLaunchCount);

      points.add(
        DailyUsagePoint(
          localDay: LocalDayKey.fromDateTime(days[i]),
          totalScreenTime: Duration(milliseconds: totalMs),
          totalLaunchCount: totalLaunches,
        ),
      );
    }

    return points.toIList();
  }

  // ---------------------------------------------------------------------------
  // getAppDetail
  // ---------------------------------------------------------------------------

  @override
  Future<AppUsageDetail> getAppDetail({
    required AndroidAppInfo appInfo,
    required String packageId,
    required DateTimeRange window,
  }) async {
    // Fetch aggregate stats, inactive status, and daily trend concurrently.
    final days = _generateDays(window);

    final (aggregateResults, dailyResults) = await (
      Future.wait<Object?>([
        _usageStatsManager.getAppUsageStats(
          packageId: packageId,
          startDate: window.start.dayStart,
          endDate: window.end.dayEnd,
        ),
        _usageStatsManager.isAppInactive(packageId: packageId),
      ]),
      Future.wait(
        days.map(
          (day) => _usageStatsManager.getAppUsageStats(
            packageId: packageId,
            startDate: day.dayStart,
            endDate: day.dayEnd,
            includeIcons: false,
          ),
        ),
      ),
    ).wait;

    final appStats = aggregateResults[0] as UsageStats?;
    final isInactive = aggregateResults[1] as bool;

    final trend = <DailyUsagePoint>[];
    for (var i = 0; i < days.length; i++) {
      final dayStat = dailyResults[i];
      trend.add(
        DailyUsagePoint(
          localDay: LocalDayKey.fromDateTime(days[i]),
          totalScreenTime: dayStat?.totalDuration ?? Duration.zero,
          totalLaunchCount: dayStat?.totalLaunchCount ?? 0,
        ),
      );
    }

    return AppUsageDetail(
      appInfo: appInfo,
      totalDuration: appStats?.totalDuration ?? Duration.zero,
      launchCount: appStats?.totalLaunchCount ?? 0,
      lastTimeUsed: appStats?.lastTimeUsed,
      dailyTrend: trend.toIList(),
      isInactive: isInactive,
    );
  }

  // ---------------------------------------------------------------------------
  // getDeviceEventSnapshot
  // ---------------------------------------------------------------------------

  @override
  Future<DeviceEventSnapshot> getDeviceEventSnapshot({
    required DateTimeRange window,
    UsageStatsInterval intervalType = UsageStatsInterval.daily,
  }) async {
    final eventStats = await _usageStatsManager.getEventStats(
      startDate: window.start.dayStart,
      endDate: window.end.dayEnd,
      intervalType: intervalType,
    );

    var screenOnCount = 0;
    var screenOnMs = 0;
    var unlockCount = 0;

    for (final entry in eventStats) {
      final type = entry.eventType;
      if (type == UsageEventType.screenInteractive) {
        screenOnCount += entry.count;
        screenOnMs += entry.totalTime.inMilliseconds;
      } else if (type == UsageEventType.keyguardHidden) {
        unlockCount += entry.count;
      }
    }

    return DeviceEventSnapshot(
      screenOnCount: screenOnCount,
      totalScreenOnTime: Duration(milliseconds: screenOnMs),
      unlockCount: unlockCount,
      eventEntries: eventStats.toIList(),
    );
  }

  @override
  Future<DeviceEventSnapshot> getExactDeviceEventSnapshot({required DateTimeRange window}) async {
    final events = await _usageStatsManager.getUsageEvents(
      startDate: window.start,
      endDate: window.end,
      eventTypes: const <UsageEventType>[
        UsageEventType.screenInteractive,
        UsageEventType.screenNonInteractive,
        UsageEventType.keyguardHidden,
      ],
    );

    return _buildExactDeviceEventSnapshot(window: window, events: events);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Groups apps by category and returns buckets sorted by duration descending.
  IList<CategoryUsageBucket> _buildCategoryBreakdown({required List<UsageStats> statsList, required int totalMs}) {
    final buckets = <String?, _MutableCategoryBucket>{};

    for (final stat in statsList) {
      final category = stat.appInfo.category;
      final bucket = buckets.putIfAbsent(category, () => _MutableCategoryBucket());
      bucket.durationMs += stat.totalDuration.inMilliseconds;
      bucket.appCount += 1;
    }

    final sorted = buckets.entries.toList()..sort((a, b) => b.value.durationMs.compareTo(a.value.durationMs));

    return sorted.map((e) {
      return CategoryUsageBucket(
        category: e.key,
        totalDuration: Duration(milliseconds: e.value.durationMs),
        appCount: e.value.appCount,
        shareOfTotal: totalMs > 0 ? e.value.durationMs / totalMs : 0,
      );
    }).toIList();
  }

  DeviceEventSnapshot _buildExactDeviceEventSnapshot({
    required DateTimeRange window,
    required List<UsageEvent> events,
  }) {
    final sortedEvents = List<UsageEvent>.of(events)..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    var screenOnCount = 0;
    var unlockCount = 0;
    var screenOnMs = 0;
    DateTime? activeScreenOnStart;

    for (final event in sortedEvents) {
      final timestamp = _clipInstantToWindow(event.timestamp, window);
      switch (event.eventType) {
        case UsageEventType.screenInteractive:
          screenOnCount += 1;
          activeScreenOnStart ??= timestamp;
          break;
        case UsageEventType.screenNonInteractive:
          final start = activeScreenOnStart;
          if (start != null && timestamp.isAfter(start)) {
            screenOnMs += timestamp.difference(start).inMilliseconds;
          }
          activeScreenOnStart = null;
          break;
        case UsageEventType.keyguardHidden:
          if (!event.timestamp.isBefore(window.start) && !event.timestamp.isAfter(window.end)) {
            unlockCount += 1;
          }
          break;
        case UsageEventType.activityResumed:
        case UsageEventType.activityPaused:
        case UsageEventType.activityStopped:
        case UsageEventType.configurationChange:
        case UsageEventType.userInteraction:
        case UsageEventType.shortcutInvocation:
        case UsageEventType.keyguardShown:
        case UsageEventType.foregroundServiceStart:
        case UsageEventType.foregroundServiceStop:
        case UsageEventType.deviceShutdown:
        case UsageEventType.deviceStartup:
        case UsageEventType.standbyBucketChanged:
        case UsageEventType.unknown:
          break;
      }
    }

    final start = activeScreenOnStart;
    if (start != null && window.end.isAfter(start)) {
      screenOnMs += window.end.difference(start).inMilliseconds;
    }

    return DeviceEventSnapshot(
      screenOnCount: screenOnCount,
      totalScreenOnTime: Duration(milliseconds: screenOnMs),
      unlockCount: unlockCount,
      eventEntries: const IList<DeviceEventStats>.empty(),
    );
  }

  DateTime _clipInstantToWindow(DateTime instant, DateTimeRange window) {
    if (instant.isBefore(window.start)) {
      return window.start;
    }
    if (instant.isAfter(window.end)) {
      return window.end;
    }
    return instant;
  }

  /// Returns the number of calendar days spanned by [window] (inclusive).
  int _dayCount(DateTimeRange window) {
    final startDay = window.start.dayStart;
    final endDay = window.end.dayStart;
    return endDay.difference(startDay).inDays + 1;
  }

  /// Generates a [DateTime] for each calendar day in [window] (inclusive).
  List<DateTime> _generateDays(DateTimeRange window) {
    final startDay = window.start.dayStart;
    final endDay = window.end.dayStart;
    final dayCount = endDay.difference(startDay).inDays + 1;

    return List<DateTime>.generate(dayCount, (i) => startDay.add(Duration(days: i)), growable: false);
  }
}

/// Mutable accumulator used during category grouping.
final class _MutableCategoryBucket {
  int durationMs = 0;
  int appCount = 0;
}
