import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/features/streaks/common/model/streak_extensions.dart';

extension type const LocalDayKey(String value) implements String {
  factory LocalDayKey.fromDateTime(DateTime dateTime) {
    return LocalDayKey(dateTime.localDayKey);
  }

  factory LocalDayKey.fromDb(String value) {
    return LocalDayKey(value);
  }

  String get dbValue => value;

  DateTime? get localDate => value.localDayDate;
}

extension type const BestStreakDays(int value) implements int {
  const BestStreakDays.zero() : this(0);

  factory BestStreakDays.fromQualifiedDays({
    required ISet<LocalDayKey> qualifiedDays,
  }) {
    if (qualifiedDays.isEmpty) {
      return const BestStreakDays.zero();
    }

    final sortedDays = qualifiedDays.toList(growable: false)..sort();

    DateTime? previousDay;
    var currentRun = 0;
    var bestRun = 0;

    for (final dayKey in sortedDays) {
      final day = dayKey.localDate;
      if (day == null) {
        continue;
      }

      if (previousDay != null && day.difference(previousDay).inDays == 1) {
        currentRun += 1;
      } else {
        currentRun = 1;
      }

      if (currentRun > bestRun) {
        bestRun = currentRun;
      }

      previousDay = day;
    }

    return BestStreakDays(bestRun);
  }
}

extension type const CurrentStreakDays(int value) implements int {
  const CurrentStreakDays.zero() : this(0);

  factory CurrentStreakDays.fromQualifiedDays({
    required DateTime todayLocal,
    required ISet<LocalDayKey> qualifiedDays,
  }) {
    var streak = 0;
    var dayCursor = DateTime(todayLocal.year, todayLocal.month, todayLocal.day);

    while (qualifiedDays.contains(LocalDayKey.fromDateTime(dayCursor))) {
      streak += 1;
      dayCursor = dayCursor.subtract(const Duration(days: 1));
    }

    return CurrentStreakDays(streak);
  }
}

extension type const TargetMinutesPerDay(int value) implements int {
  const TargetMinutesPerDay.ten() : this(10);
}
