import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_entry.dart';
import 'package:pauza/src/features/stats/usage_stats/model/category_usage_bucket.dart';

/// Aggregated usage statistics snapshot for a queried time window.
///
/// Contains top-level KPIs, per-app breakdown, and per-category breakdown.
/// Designed to be consumed directly by chart and KPI card widgets.
@immutable
final class UsageStatsSnapshot extends Equatable {
  const UsageStatsSnapshot({
    required this.totalScreenTime,
    required this.totalLaunchCount,
    required this.appUsageEntries,
    required this.categoryBreakdown,
    required this.averageDailyScreenTime,
  });

  /// Combined foreground time across all apps.
  final Duration totalScreenTime;

  /// Combined launch count across all apps.
  final int totalLaunchCount;

  /// Per-app breakdown, sorted by [totalDuration] descending.
  final IList<AppUsageEntry> appUsageEntries;

  /// Per-category breakdown, sorted by [totalDuration] descending.
  final IList<CategoryUsageBucket> categoryBreakdown;

  /// [totalScreenTime] divided by the number of days in the queried window.
  final Duration averageDailyScreenTime;

  /// The app with the highest foreground time, or `null` if no usage.
  AppUsageEntry? get mostUsedApp => appUsageEntries.isEmpty ? null : appUsageEntries.first;

  /// Whether there is any recorded usage in this snapshot.
  bool get isEmpty => appUsageEntries.isEmpty;

  @override
  List<Object?> get props => <Object?>[
    totalScreenTime,
    totalLaunchCount,
    appUsageEntries,
    categoryBreakdown,
    averageDailyScreenTime,
  ];

  @override
  String toString() =>
      'UsageStatsSnapshot('
      'screenTime: $totalScreenTime, '
      'launches: $totalLaunchCount, '
      'apps: ${appUsageEntries.length}, '
      'categories: ${categoryBreakdown.length})';
}
