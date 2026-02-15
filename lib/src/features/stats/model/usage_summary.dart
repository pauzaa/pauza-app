import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/stats/model/usage_category_bucket.dart';

@immutable
class UsageTrendPoint {
  const UsageTrendPoint({required this.day, required this.duration});

  final DateTime day;
  final Duration duration;

  @override
  String toString() => 'UsageTrendPoint(day: $day, duration: $duration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageTrendPoint &&
          other.day == day &&
          other.duration == duration;

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
  int get hashCode => Object.hash(
    totalDuration,
    dailyAverage,
    deltaPercent,
    Object.hashAll(buckets.entries),
    Object.hashAll(trend),
  );
}
