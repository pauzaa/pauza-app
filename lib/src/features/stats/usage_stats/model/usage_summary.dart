import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_category_bucket.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

@immutable
class UsageTrendPoint {
  const UsageTrendPoint({required this.day, required this.duration});

  final DateTime day;
  final Duration duration;

  @override
  String toString() => 'UsageTrendPoint(day: $day, duration: $duration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UsageTrendPoint && other.day == day && other.duration == duration;

  @override
  int get hashCode => Object.hash(day, duration);
}

@immutable
class UsageSummary {
  const UsageSummary({
    required this.totalDuration,
    required this.dailyAverage,
    required this.deltaPercent,
    required this.buckets,
    required this.trend,
  });

  factory UsageSummary.buildSummary({
    required IList<UsageStats> current,
    required IList<UsageStats> previous,
    required DateTimeRange window,
  }) {
    final currentTotal = current.fold<Duration>(Duration.zero, (sum, item) => sum + item.totalDuration);
    final previousTotal = previous.fold<Duration>(Duration.zero, (sum, item) => sum + item.totalDuration);

    final bucketTotals = <UsageCategoryBucket, Duration>{
      UsageCategoryBucket.social: Duration.zero,
      UsageCategoryBucket.productivity: Duration.zero,
      UsageCategoryBucket.other: Duration.zero,
    };

    for (final item in current) {
      final bucket = UsageCategoryBucket.fromCategory(item.appInfo.category);
      bucketTotals[bucket] = (bucketTotals[bucket] ?? Duration.zero) + item.totalDuration;
    }

    final trendDurations = <DateTime, Duration>{};
    for (var i = 0; i < window.inclusiveDays; i++) {
      final day = window.start.add(Duration(days: i)).dayStart;
      trendDurations[day] = Duration.zero;
    }

    for (final item in current) {
      final basis = item.lastTimeUsed ?? item.bucketStart ?? window.start;
      final key = basis.dayStart;
      if (!trendDurations.containsKey(key)) {
        continue;
      }
      trendDurations[key] = (trendDurations[key] ?? Duration.zero) + item.totalDuration;
    }

    final trend =
        trendDurations.entries
            .map((entry) => UsageTrendPoint(day: entry.key, duration: entry.value))
            .toList(growable: false)
          ..sort((a, b) => a.day.compareTo(b.day));

    final deltaPercent = previousTotal.inMilliseconds == 0
        ? null
        : ((currentTotal.inMilliseconds - previousTotal.inMilliseconds) / previousTotal.inMilliseconds) * 100;

    return UsageSummary(
      totalDuration: currentTotal,
      dailyAverage: Duration(
        milliseconds: window.inclusiveDays == 0 ? 0 : currentTotal.inMilliseconds ~/ window.inclusiveDays,
      ),
      deltaPercent: deltaPercent,
      buckets: bucketTotals,
      trend: trend,
    );
  }

  final Duration totalDuration;
  final Duration dailyAverage;
  final double? deltaPercent;
  final Map<UsageCategoryBucket, Duration> buckets;
  final List<UsageTrendPoint> trend;

  @override
  String toString() {
    return 'UsageSummary(totalDuration: $totalDuration, dailyAverage: $dailyAverage, '
        'deltaPercent: $deltaPercent, buckets: $buckets, trend: $trend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UsageSummary &&
            other.totalDuration == totalDuration &&
            other.dailyAverage == dailyAverage &&
            other.deltaPercent == deltaPercent &&
            mapEquals(other.buckets, buckets) &&
            listEquals(other.trend, trend);
  }

  @override
  int get hashCode =>
      Object.hash(totalDuration, dailyAverage, deltaPercent, Object.hashAll(buckets.entries), Object.hashAll(trend));
}
