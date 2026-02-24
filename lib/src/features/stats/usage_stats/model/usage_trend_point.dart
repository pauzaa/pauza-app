import 'package:flutter/foundation.dart';

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
