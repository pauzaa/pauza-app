import 'package:flutter/foundation.dart';

@immutable
final class HomeDashboardMetrics {
  const HomeDashboardMetrics({this.streakDays, this.focusedDuration});

  final int? streakDays;
  final Duration? focusedDuration;
}
