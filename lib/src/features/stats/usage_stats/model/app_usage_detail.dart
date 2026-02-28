import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/stats/usage_stats/model/daily_usage_point.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

/// Detailed usage data for a single app, including a daily trend.
///
/// Used by the app-detail drill-down screen.
@immutable
final class AppUsageDetail extends Equatable {
  const AppUsageDetail({
    required this.appInfo,
    required this.totalDuration,
    required this.launchCount,
    required this.dailyTrend,
    required this.isInactive,
    this.lastTimeUsed,
  });

  /// Android app metadata (name, icon, package, category, isSystemApp).
  final AndroidAppInfo appInfo;

  /// Total foreground time in the queried window.
  final Duration totalDuration;

  /// Number of launches in the queried window.
  final int launchCount;

  /// Last foreground usage timestamp.
  final DateTime? lastTimeUsed;

  /// Per-day usage breakdown for trend charting.
  final IList<DailyUsagePoint> dailyTrend;

  /// Whether Android currently considers this app inactive.
  final bool isInactive;

  @override
  List<Object?> get props => <Object?>[appInfo, totalDuration, launchCount, lastTimeUsed, dailyTrend, isInactive];

  @override
  String toString() =>
      'AppUsageDetail(${appInfo.name}, '
      'duration: $totalDuration, '
      'launches: $launchCount, '
      'days: ${dailyTrend.length}, '
      'inactive: $isInactive)';
}
