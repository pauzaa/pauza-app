import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_detail.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_entry.dart';
import 'package:pauza/src/features/stats/usage_stats/model/category_usage_bucket.dart';
import 'package:pauza/src/features/stats/usage_stats/model/daily_usage_point.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_event_snapshot.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_stats_snapshot.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';
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
  Future<AppUsageDetail> getAppDetail({required String packageId, required DateTimeRange window});

  /// Returns device-level event statistics (screen-on count, unlock count).
  ///
  /// Requires Android 9+ (API 28+). On lower API levels the plugin throws
  /// [PauzaUnsupportedError].
  Future<DeviceEventSnapshot> getDeviceEventSnapshot({required DateTimeRange window, UsageStatsInterval intervalType});
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
    final points = <DailyUsagePoint>[];

    for (final day in days) {
      final dayStart = day.dayStart;
      final dayEnd = day.dayEnd;

      final statsList = await _usageStatsManager.getUsageStats(
        startDate: dayStart,
        endDate: dayEnd,
        includeIcons: false,
      );

      final totalMs = statsList.fold<int>(0, (sum, s) => sum + s.totalDuration.inMilliseconds);
      final totalLaunches = statsList.fold<int>(0, (sum, s) => sum + s.totalLaunchCount);

      points.add(
        DailyUsagePoint(
          localDay: LocalDayKey.fromDateTime(day),
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
  Future<AppUsageDetail> getAppDetail({required String packageId, required DateTimeRange window}) async {
    // Fetch aggregate stats and inactive status concurrently.
    final results = await Future.wait<Object?>([
      _usageStatsManager.getAppUsageStats(
        packageId: packageId,
        startDate: window.start.dayStart,
        endDate: window.end.dayEnd,
      ),
      _usageStatsManager.isAppInactive(packageId: packageId),
    ]);

    final appStats = results[0] as UsageStats?;
    final isInactive = results[1] as bool;

    // Build daily trend.
    final days = _generateDays(window);
    final trend = <DailyUsagePoint>[];

    for (final day in days) {
      final dayStat = await _usageStatsManager.getAppUsageStats(
        packageId: packageId,
        startDate: day.dayStart,
        endDate: day.dayEnd,
        includeIcons: false,
      );

      trend.add(
        DailyUsagePoint(
          localDay: LocalDayKey.fromDateTime(day),
          totalScreenTime: dayStat?.totalDuration ?? Duration.zero,
          totalLaunchCount: dayStat?.totalLaunchCount ?? 0,
        ),
      );
    }

    // When the app has no usage in the range, appStats is null.
    // We still need an AppInfo to display the detail screen. Re-fetch with
    // icons enabled so the caller always gets metadata.
    final resolvedStats =
        appStats ??
        await _usageStatsManager.getAppUsageStats(
          packageId: packageId,
          startDate: window.start.dayStart,
          endDate: window.end.dayEnd,
        );

    return AppUsageDetail(
      appInfo: resolvedStats!.appInfo,
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
