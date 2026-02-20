import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/streaks/common/model/streak_constants.dart';
import 'package:pauza/src/features/streaks/common/model/streak_daily_aggregate.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';

@immutable
final class StreakSnapshot {
  const StreakSnapshot({
    required this.asOfLocal,
    required this.targetDurationPerDay,
    required this.todayEffectiveDuration,
    required this.currentStreakDays,
    required this.bestStreakDays,
  });

  final DateTime asOfLocal;
  final Duration targetDurationPerDay;
  final Duration todayEffectiveDuration;
  final CurrentStreakDays currentStreakDays;
  final BestStreakDays bestStreakDays;
  bool get todayQualified => todayEffectiveDuration >= targetDurationPerDay;

  factory StreakSnapshot.zero({required DateTime asOfLocal}) {
    return StreakSnapshot(
      asOfLocal: asOfLocal,
      targetDurationPerDay: StreakConstants.targetDurationPerDay,
      todayEffectiveDuration: Duration.zero,
      currentStreakDays: const CurrentStreakDays.zero(),
      bestStreakDays: const BestStreakDays.zero(),
    );
  }

  factory StreakSnapshot.fromDailyAggregates({required DateTime asOfLocal, required IList<StreakDailyAggregate> rows}) {
    final effectiveDurationByDay = <LocalDayKey, Duration>{};
    final qualifiedDays = <LocalDayKey>{};

    for (final row in rows) {
      effectiveDurationByDay[row.localDay] = row.effectiveDuration;
      if (row.qualified) {
        qualifiedDays.add(row.localDay);
      }
    }

    final todayKey = LocalDayKey.fromDateTime(asOfLocal);
    final todayEffectiveDuration = effectiveDurationByDay[todayKey] ?? Duration.zero;
    final qualifiedDaySet = qualifiedDays.toISet();

    return StreakSnapshot(
      asOfLocal: asOfLocal,
      targetDurationPerDay: StreakConstants.targetDurationPerDay,
      todayEffectiveDuration: todayEffectiveDuration,
      currentStreakDays: CurrentStreakDays.fromQualifiedDays(todayLocal: asOfLocal, qualifiedDays: qualifiedDaySet),
      bestStreakDays: BestStreakDays.fromQualifiedDays(qualifiedDays: qualifiedDaySet),
    );
  }

  @override
  String toString() {
    return 'StreakSnapshot('
        'asOfLocal: $asOfLocal, '
        'targetDurationPerDay: $targetDurationPerDay, '
        'todayEffectiveDuration: $todayEffectiveDuration, '
        'todayQualified: $todayQualified, '
        'currentStreakDays: $currentStreakDays, '
        'bestStreakDays: $bestStreakDays'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is StreakSnapshot &&
        other.asOfLocal == asOfLocal &&
        other.targetDurationPerDay == targetDurationPerDay &&
        other.todayEffectiveDuration == todayEffectiveDuration &&
        other.currentStreakDays == currentStreakDays &&
        other.bestStreakDays == bestStreakDays;
  }

  @override
  int get hashCode {
    return Object.hash(asOfLocal, targetDurationPerDay, todayEffectiveDuration, currentStreakDays, bestStreakDays);
  }
}
