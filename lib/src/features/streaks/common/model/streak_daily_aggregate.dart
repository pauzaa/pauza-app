import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/streaks/common/model/streak_extensions.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';

@immutable
final class StreakDailyAggregate {
  const StreakDailyAggregate({
    required this.localDay,
    required this.effectiveMs,
    required this.qualified,
  });

  factory StreakDailyAggregate.fromJson(Map<String, Object?> row) {
    return StreakDailyAggregate(
      localDay: LocalDayKey.fromDb(row['local_day'] as String),
      effectiveMs: row['effective_ms'].intOrZero,
      qualified: row['qualified'].intOrZero == 1,
    );
  }

  final LocalDayKey localDay;
  final int effectiveMs;
  final bool qualified;
}
