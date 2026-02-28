import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';

/// A single day's aggregated usage data, used for trend charts.
@immutable
final class DailyUsagePoint extends Equatable {
  const DailyUsagePoint({required this.localDay, required this.totalScreenTime, required this.totalLaunchCount});

  /// The calendar day this data point represents.
  final LocalDayKey localDay;

  /// Total foreground screen time across all apps on this day.
  final Duration totalScreenTime;

  /// Total app launches across all apps on this day.
  final int totalLaunchCount;

  @override
  List<Object?> get props => <Object?>[localDay, totalScreenTime, totalLaunchCount];

  @override
  String toString() =>
      'DailyUsagePoint($localDay, '
      'screenTime: $totalScreenTime, '
      'launches: $totalLaunchCount)';
}
