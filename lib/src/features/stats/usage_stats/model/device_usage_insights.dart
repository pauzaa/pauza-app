import 'package:flutter/foundation.dart';

enum DeviceUsageInsightsSource { eventStats, usageEventsFallback }

@immutable
class DeviceUsageInsights {
  const DeviceUsageInsights({
    required this.unlockCount,
    required this.lockCount,
    required this.pickupCount,
    required this.screenOnDuration,
    required this.unlockedDuration,
    required this.screenOnSessionAverage,
    required this.unlocksPerDayAverage,
    required this.firstUnlockAt,
    required this.lastUnlockAt,
    required this.source,
  });

  final int unlockCount;
  final int lockCount;
  final int pickupCount;
  final Duration screenOnDuration;
  final Duration unlockedDuration;

  /// The average screen-on duration per pickup.
  /// `null` when [pickupCount] is zero — callers should handle this gracefully.
  final Duration? screenOnSessionAverage;
  final double unlocksPerDayAverage;
  final DateTime? firstUnlockAt;
  final DateTime? lastUnlockAt;
  final DeviceUsageInsightsSource source;

  DeviceUsageInsights copyWith({
    int? unlockCount,
    int? lockCount,
    int? pickupCount,
    Duration? screenOnDuration,
    Duration? unlockedDuration,
    Duration? screenOnSessionAverage,
    double? unlocksPerDayAverage,
    DateTime? firstUnlockAt,
    DateTime? lastUnlockAt,
    DeviceUsageInsightsSource? source,
  }) {
    return DeviceUsageInsights(
      unlockCount: unlockCount ?? this.unlockCount,
      lockCount: lockCount ?? this.lockCount,
      pickupCount: pickupCount ?? this.pickupCount,
      screenOnDuration: screenOnDuration ?? this.screenOnDuration,
      unlockedDuration: unlockedDuration ?? this.unlockedDuration,
      screenOnSessionAverage: screenOnSessionAverage ?? this.screenOnSessionAverage,
      unlocksPerDayAverage: unlocksPerDayAverage ?? this.unlocksPerDayAverage,
      firstUnlockAt: firstUnlockAt ?? this.firstUnlockAt,
      lastUnlockAt: lastUnlockAt ?? this.lastUnlockAt,
      source: source ?? this.source,
    );
  }

  @override
  String toString() {
    return 'DeviceUsageInsights('
        'unlockCount: $unlockCount, '
        'lockCount: $lockCount, '
        'pickupCount: $pickupCount, '
        'screenOnDuration: $screenOnDuration, '
        'unlockedDuration: $unlockedDuration, '
        'screenOnSessionAverage: $screenOnSessionAverage, '
        'unlocksPerDayAverage: $unlocksPerDayAverage, '
        'firstUnlockAt: $firstUnlockAt, '
        'lastUnlockAt: $lastUnlockAt, '
        'source: $source'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DeviceUsageInsights &&
            other.unlockCount == unlockCount &&
            other.lockCount == lockCount &&
            other.pickupCount == pickupCount &&
            other.screenOnDuration == screenOnDuration &&
            other.unlockedDuration == unlockedDuration &&
            other.screenOnSessionAverage == screenOnSessionAverage &&
            other.unlocksPerDayAverage == unlocksPerDayAverage &&
            other.firstUnlockAt == firstUnlockAt &&
            other.lastUnlockAt == lastUnlockAt &&
            other.source == source;
  }

  @override
  int get hashCode => Object.hash(
    unlockCount,
    lockCount,
    pickupCount,
    screenOnDuration,
    unlockedDuration,
    screenOnSessionAverage,
    unlocksPerDayAverage,
    firstUnlockAt,
    lastUnlockAt,
    source,
  );
}
