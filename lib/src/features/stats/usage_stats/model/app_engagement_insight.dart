import 'package:flutter/foundation.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

@immutable
class AppEngagementInsight {
  const AppEngagementInsight({
    required this.appInfo,
    required this.totalDuration,
    required this.totalLaunchCount,
    required this.averageSessionDuration,
    required this.launchesPerHour,
    required this.engagementScore,
  });

  final AndroidAppInfo appInfo;
  final Duration totalDuration;
  final int totalLaunchCount;
  final Duration averageSessionDuration;
  final double launchesPerHour;
  final double engagementScore;

  @override
  String toString() {
    return 'AppEngagementInsight('
        'packageId: ${appInfo.packageId}, '
        'totalDuration: $totalDuration, '
        'totalLaunchCount: $totalLaunchCount, '
        'averageSessionDuration: $averageSessionDuration, '
        'launchesPerHour: $launchesPerHour, '
        'engagementScore: $engagementScore'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppEngagementInsight &&
            other.appInfo == appInfo &&
            other.totalDuration == totalDuration &&
            other.totalLaunchCount == totalLaunchCount &&
            other.averageSessionDuration == averageSessionDuration &&
            other.launchesPerHour == launchesPerHour &&
            other.engagementScore == engagementScore;
  }

  @override
  int get hashCode =>
      Object.hash(appInfo, totalDuration, totalLaunchCount, averageSessionDuration, launchesPerHour, engagementScore);
}
