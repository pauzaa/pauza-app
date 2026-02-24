import 'dart:math' as math;

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_engagement_insight.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_usage_insights.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class StatsUsageRepository {
  Future<IList<UsageStats>> getUsageStats({required DateTime start, required DateTime end, bool includeIcons = false});

  Future<UsageStats?> getAppUsageStats({
    required String packageId,
    required DateTime start,
    required DateTime end,
    bool includeIcons = false,
  });

  Future<IList<UsageEvent>> getUsageEvents({
    required DateTime start,
    required DateTime end,
    IList<UsageEventType>? eventTypes,
  });

  Future<IList<DeviceEventStats>> getEventStats({
    required DateTime start,
    required DateTime end,
    UsageStatsInterval interval = UsageStatsInterval.daily,
  });

  Future<bool> isAppInactive({required String packageId});

  Future<AppStandbyBucket> getAppStandbyBucket();

  Future<DeviceUsageInsights> getDeviceUsageInsights({required DateTime start, required DateTime end});

  Future<IList<AppEngagementInsight>> getTopAppEngagementInsights({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  });

  Future<IMap<int, Duration>> getHourlyScreenTimeHeatmap({required DateTime start, required DateTime end});
}

class StatsUsageRepositoryImpl implements StatsUsageRepository {
  // TODO: add InstalledAppsManager once app-metadata enrichment is needed.
  StatsUsageRepositoryImpl({required UsageStatsManager usageStatsManager}) : _usageStatsManager = usageStatsManager;

  final UsageStatsManager _usageStatsManager;
  static const IList<UsageEventType> _deviceInsightsEventTypes = IListConst<UsageEventType>(<UsageEventType>[
    UsageEventType.keyguardHidden,
    UsageEventType.keyguardShown,
    UsageEventType.screenInteractive,
    UsageEventType.screenNonInteractive,
  ]);

  @override
  Future<IList<UsageStats>> getUsageStats({
    required DateTime start,
    required DateTime end,
    bool includeIcons = false,
  }) async {
    final usage = await _usageStatsManager.getUsageStats(startDate: start, endDate: end, includeIcons: includeIcons);

    return usage
        .where((stat) => stat.totalDuration > Duration.zero)
        .toIList()
        .sort((a, b) => b.totalDuration.compareTo(a.totalDuration));
  }

  @override
  Future<UsageStats?> getAppUsageStats({
    required String packageId,
    required DateTime start,
    required DateTime end,
    bool includeIcons = false,
  }) {
    return _usageStatsManager.getAppUsageStats(
      packageId: packageId,
      startDate: start,
      endDate: end,
      includeIcons: includeIcons,
    );
  }

  @override
  Future<IList<UsageEvent>> getUsageEvents({
    required DateTime start,
    required DateTime end,
    IList<UsageEventType>? eventTypes,
  }) async {
    final events = await _usageStatsManager.getUsageEvents(
      startDate: start,
      endDate: end,
      eventTypes: eventTypes?.toList(growable: false),
    );
    return events.toIList();
  }

  @override
  Future<IList<DeviceEventStats>> getEventStats({
    required DateTime start,
    required DateTime end,
    UsageStatsInterval interval = UsageStatsInterval.daily,
  }) async {
    final stats = await _usageStatsManager.getEventStats(startDate: start, endDate: end, intervalType: interval);
    return stats.toIList();
  }

  @override
  Future<bool> isAppInactive({required String packageId}) {
    return _usageStatsManager.isAppInactive(packageId: packageId);
  }

  @override
  Future<AppStandbyBucket> getAppStandbyBucket() {
    return _usageStatsManager.getAppStandbyBucket();
  }

  @override
  Future<DeviceUsageInsights> getDeviceUsageInsights({required DateTime start, required DateTime end}) async {
    final (eventStats, fallbackEvents, source) = await _safeGetEventStatsOrFallback(start: start, end: end);

    final int unlockCount;
    final int lockCount;
    final int pickupCount;
    final Duration screenOnDuration;
    final Duration unlockedDuration;
    final DateTime? firstUnlockAt;
    final DateTime? lastUnlockAt;

    if (source == DeviceUsageInsightsSource.eventStats && eventStats != null) {
      // Index the event-stats once to avoid O(n) scans per lookup.
      final statsMap = Map<UsageEventType, DeviceEventStats>.fromEntries(
        eventStats.map((s) => MapEntry(s.eventType, s)),
      );
      unlockCount = statsMap[UsageEventType.keyguardHidden]?.count ?? 0;
      lockCount = statsMap[UsageEventType.keyguardShown]?.count ?? 0;
      pickupCount = statsMap[UsageEventType.screenInteractive]?.count ?? 0;
      screenOnDuration = statsMap[UsageEventType.screenInteractive]?.totalTime ?? Duration.zero;
      unlockedDuration = statsMap[UsageEventType.keyguardHidden]?.totalTime ?? Duration.zero;
      // Derive timestamps from the event-stats model — no extra IPC call needed.
      firstUnlockAt = statsMap[UsageEventType.keyguardHidden]?.firstTimestamp;
      lastUnlockAt = statsMap[UsageEventType.keyguardHidden]?.lastTimestamp;
    } else {
      // Fallback path: compute everything from raw usage events.
      final relevantEvents = fallbackEvents!;
      final unlockEvents = relevantEvents
          .where((event) => event.eventType == UsageEventType.keyguardHidden)
          .toIList()
          .sort((a, b) => a.timestamp.compareTo(b.timestamp));

      unlockCount = unlockEvents.length;
      lockCount = relevantEvents.where((event) => event.eventType == UsageEventType.keyguardShown).length;
      pickupCount = relevantEvents.where((event) => event.eventType == UsageEventType.screenInteractive).length;
      screenOnDuration = _sumDurationBetweenEventPairs(
        events: relevantEvents,
        startType: UsageEventType.screenInteractive,
        endType: UsageEventType.screenNonInteractive,
        start: start,
        end: end,
      );
      unlockedDuration = _sumDurationBetweenEventPairs(
        events: relevantEvents,
        startType: UsageEventType.keyguardHidden,
        endType: UsageEventType.keyguardShown,
        start: start,
        end: end,
      );
      firstUnlockAt = unlockEvents.isEmpty ? null : unlockEvents.first.timestamp;
      lastUnlockAt = unlockEvents.isEmpty ? null : unlockEvents.last.timestamp;
    }

    final safeDayCount = _inclusiveDayCount(start: start, end: end);

    return DeviceUsageInsights(
      unlockCount: unlockCount,
      lockCount: lockCount,
      pickupCount: pickupCount,
      screenOnDuration: screenOnDuration,
      unlockedDuration: unlockedDuration,
      // Returns null (not a fabricated value) when there are no pickups.
      screenOnSessionAverage: pickupCount <= 0
          ? null
          : Duration(milliseconds: screenOnDuration.inMilliseconds ~/ pickupCount),
      unlocksPerDayAverage: unlockCount / safeDayCount,
      firstUnlockAt: firstUnlockAt,
      lastUnlockAt: lastUnlockAt,
      source: source,
    );
  }

  @override
  Future<IList<AppEngagementInsight>> getTopAppEngagementInsights({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  }) async {
    if (limit <= 0) {
      return const IListConst<AppEngagementInsight>(<AppEngagementInsight>[]);
    }

    final usageStats = await getUsageStats(start: start, end: end);
    final windowHours = _windowHours(start: start, end: end);

    // getUsageStats guarantees totalDuration > zero, so no extra filter is needed.
    // Engagement score: both dimensions are normalized to [0, 1] relative to the
    // window's max values so they are on the same scale.
    // Score = 0.4 * (duration / maxDuration) + 0.6 * (launches / maxLaunches)
    final maxDuration = usageStats.fold<int>(1, (m, u) => math.max(m, u.totalDuration.inMilliseconds));
    final maxLaunches = usageStats.fold<int>(1, (m, u) => math.max(m, u.totalLaunchCount));

    final insights = usageStats
        .map((usage) {
          final launches = usage.totalLaunchCount;
          final safeLaunches = launches <= 0 ? 1 : launches;
          final avgSessionDuration = Duration(milliseconds: usage.totalDuration.inMilliseconds ~/ safeLaunches);
          final engagementScore =
              0.4 * (usage.totalDuration.inMilliseconds / maxDuration) + 0.6 * (usage.totalLaunchCount / maxLaunches);
          return AppEngagementInsight(
            appInfo: usage.appInfo,
            totalDuration: usage.totalDuration,
            totalLaunchCount: launches,
            averageSessionDuration: avgSessionDuration,
            launchesPerHour: launches / windowHours,
            engagementScore: engagementScore,
          );
        })
        .toIList()
        .sort((a, b) => b.engagementScore.compareTo(a.engagementScore));

    // take() on a list shorter than limit is a no-op — no branch needed.
    return insights.take(limit).toIList();
  }

  @override
  Future<IMap<int, Duration>> getHourlyScreenTimeHeatmap({required DateTime start, required DateTime end}) async {
    final usageEvents = await getUsageEvents(
      start: start,
      end: end,
      eventTypes: const IListConst<UsageEventType>(<UsageEventType>[
        UsageEventType.activityResumed,
        UsageEventType.activityPaused,
        UsageEventType.activityStopped,
      ]),
    );

    final intervals = _buildIntervalsFromUsageEvents(events: usageEvents, start: start, end: end);
    if (intervals.isNotEmpty) {
      return _accumulateDurationsByHour(intervals: intervals, start: start, end: end);
    }

    // Fallback: event-level data unavailable. Spread each app's total duration
    // evenly across all 24 hours as an approximation.
    final fallbackUsageStats = await getUsageStats(start: start, end: end);
    final buckets = _emptyHeatmapBuckets();
    for (final usage in fallbackUsageStats) {
      if (usage.totalDuration <= Duration.zero) {
        continue;
      }
      final perHour = Duration(milliseconds: usage.totalDuration.inMilliseconds ~/ 24);
      for (var h = 0; h < 24; h++) {
        buckets[h] = (buckets[h] ?? Duration.zero) + perHour;
      }
    }
    return buckets.lock;
  }

  Future<(IList<DeviceEventStats>?, IList<UsageEvent>?, DeviceUsageInsightsSource)> _safeGetEventStatsOrFallback({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final stats = await getEventStats(start: start, end: end);
      return (stats, null, DeviceUsageInsightsSource.eventStats);
    } on PauzaUnsupportedError {
      final fallbackEvents = await getUsageEvents(start: start, end: end, eventTypes: _deviceInsightsEventTypes);
      return (null, fallbackEvents, DeviceUsageInsightsSource.usageEventsFallback);
    }
  }

  IList<({DateTime start, DateTime end})> _buildIntervalsFromUsageEvents({
    required IList<UsageEvent> events,
    required DateTime start,
    required DateTime end,
  }) {
    final byTimestamp = events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final activeStartByPackage = <String, DateTime>{};
    final intervals = <({DateTime start, DateTime end})>[];

    for (final event in byTimestamp) {
      if (event.eventType == UsageEventType.activityResumed) {
        activeStartByPackage[event.packageName] = event.timestamp;
        continue;
      }

      final isCloseEvent =
          event.eventType == UsageEventType.activityPaused || event.eventType == UsageEventType.activityStopped;
      if (!isCloseEvent) {
        continue;
      }

      final activeStart = activeStartByPackage.remove(event.packageName);
      if (activeStart == null) {
        continue;
      }
      final clipped = _clipInterval(start: activeStart, end: event.timestamp, min: start, max: end);
      if (clipped != null) {
        intervals.add(clipped);
      }
    }

    for (final activeStart in activeStartByPackage.values) {
      final clipped = _clipInterval(start: activeStart, end: end, min: start, max: end);
      if (clipped != null) {
        intervals.add(clipped);
      }
    }

    return intervals.toIList();
  }

  IMap<int, Duration> _accumulateDurationsByHour({
    required IList<({DateTime start, DateTime end})> intervals,
    required DateTime start,
    required DateTime end,
  }) {
    final buckets = _emptyHeatmapBuckets();

    // Intervals are already clipped by _buildIntervalsFromUsageEvents — no
    // need to clip again here.
    for (final interval in intervals) {
      var cursor = interval.start;
      final intervalEnd = interval.end;
      while (cursor.isBefore(intervalEnd)) {
        final nextHour = DateTime(cursor.year, cursor.month, cursor.day, cursor.hour + 1);
        final segmentEnd = nextHour.isBefore(intervalEnd) ? nextHour : intervalEnd;
        final segment = segmentEnd.difference(cursor);
        buckets[cursor.hour] = (buckets[cursor.hour] ?? Duration.zero) + segment;
        cursor = segmentEnd;
      }
    }

    return buckets.lock;
  }

  Duration _sumDurationBetweenEventPairs({
    required IList<UsageEvent> events,
    required UsageEventType startType,
    required UsageEventType endType,
    required DateTime start,
    required DateTime end,
  }) {
    final sortedEvents = events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    var total = Duration.zero;
    DateTime? activeStart;

    for (final event in sortedEvents) {
      if (event.eventType == startType) {
        if (activeStart != null) {
          // Two consecutive start events without an intervening end (e.g. a
          // re-wake without a sleep). Close the previous interval at the new
          // event's timestamp to avoid losing that time.
          final clippedEnd = event.timestamp.isBefore(end) ? event.timestamp : end;
          if (clippedEnd.isAfter(activeStart)) {
            total += clippedEnd.difference(activeStart);
          }
        }
        activeStart = event.timestamp.isAfter(start) ? event.timestamp : start;
        continue;
      }
      if (event.eventType == endType && activeStart != null) {
        final clippedEnd = event.timestamp.isBefore(end) ? event.timestamp : end;
        if (clippedEnd.isAfter(activeStart)) {
          total += clippedEnd.difference(activeStart);
        }
        activeStart = null;
      }
    }

    if (activeStart != null && end.isAfter(activeStart)) {
      total += end.difference(activeStart);
    }

    return total;
  }

  ({DateTime start, DateTime end})? _clipInterval({
    required DateTime start,
    required DateTime end,
    required DateTime min,
    required DateTime max,
  }) {
    final clippedStart = start.isAfter(min) ? start : min;
    final clippedEnd = end.isBefore(max) ? end : max;
    if (!clippedEnd.isAfter(clippedStart)) {
      return null;
    }
    return (start: clippedStart, end: clippedEnd);
  }

  Map<int, Duration> _emptyHeatmapBuckets() {
    return <int, Duration>{for (int hour = 0; hour < 24; hour++) hour: Duration.zero};
  }

  int _inclusiveDayCount({required DateTime start, required DateTime end}) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    final daySpan = endDay.difference(startDay).inDays + 1;
    return daySpan <= 0 ? 1 : daySpan;
  }

  double _windowHours({required DateTime start, required DateTime end}) {
    final minutes = end.difference(start).inMinutes;
    if (minutes <= 0) {
      return 1;
    }
    return minutes / 60;
  }
}
