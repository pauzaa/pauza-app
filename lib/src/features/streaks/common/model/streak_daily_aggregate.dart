import 'package:flutter/foundation.dart';
import 'package:pauza/src/core/common/local_day_extensions.dart';
import 'package:pauza/src/core/common/model/local_day_key.dart';

@immutable
final class StreakDailyAggregate {
  const StreakDailyAggregate({required this.localDay, required this.effectiveDuration, required this.qualified});

  factory StreakDailyAggregate.fromJson(Map<String, Object?> row) {
    return StreakDailyAggregate(
      localDay: LocalDayKey.fromDb(row['local_day'] as String),
      effectiveDuration: Duration(milliseconds: row['effective_ms'].intOrZero),
      qualified: row['qualified'].intOrZero == 1,
    );
  }

  final LocalDayKey localDay;
  final Duration effectiveDuration;
  final bool qualified;
}
