import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

/// Per-app usage breakdown within a queried time window.
@immutable
final class AppUsageEntry extends Equatable {
  const AppUsageEntry({
    required this.appInfo,
    required this.totalDuration,
    required this.launchCount,
    required this.shareOfTotal,
    this.lastTimeUsed,
  });

  /// Android app metadata (name, icon, package, category, isSystemApp).
  final AndroidAppInfo appInfo;

  /// Total foreground time for this app in the queried window.
  final Duration totalDuration;

  /// Number of times the app was launched (ACTIVITY_RESUMED count).
  final int launchCount;

  /// Fraction of total screen time this app represents (0.0 - 1.0).
  final double shareOfTotal;

  /// Last foreground usage timestamp within the queried window.
  final DateTime? lastTimeUsed;

  @override
  List<Object?> get props => <Object?>[appInfo, totalDuration, launchCount, shareOfTotal, lastTimeUsed];

  @override
  String toString() =>
      'AppUsageEntry(${appInfo.name}, '
      'duration: $totalDuration, '
      'launches: $launchCount, '
      'share: ${(shareOfTotal * 100).toStringAsFixed(1)}%)';
}
