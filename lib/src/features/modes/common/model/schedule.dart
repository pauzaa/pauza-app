import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/common/model/week_day.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

@immutable
class Schedule {
  const Schedule({
    required this.days,
    required this.start,
    required this.end,
    required this.enabled,
  });

  const Schedule.initial()
    : this(
        days: const ISet.empty(),
        enabled: false,
        start: const TimeOfDay(hour: 8, minute: 0),
        end: const TimeOfDay(hour: 18, minute: 00),
      );

  final ISet<WeekDay> days;
  final bool enabled;
  final TimeOfDay start;
  final TimeOfDay end;

  RestrictionSchedule toRestrictionSchedule() => RestrictionSchedule(
    daysOfWeekIso: days.map((day) => day.dayIndex).toSet(),
    startMinutes: start.toMinutesFromMidnight,
    endMinutes: end.toMinutesFromMidnight,
  );

  Schedule copyWith({
    ISet<WeekDay>? days,
    bool? enabled,
    TimeOfDay? start,
    TimeOfDay? end,
  }) => Schedule(
    days: days ?? this.days,
    enabled: enabled ?? this.enabled,
    start: start ?? this.start,
    end: end ?? this.end,
  );

  @override
  String toString() =>
      'Schedule(days: $days, enabled: $enabled, start: $start, end: $end)';
}

extension TimeOfDayX on TimeOfDay {
  int get toMinutesFromMidnight => hour * 60 + minute;
  static TimeOfDay fromMinutesFromMidnight(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
