import 'package:flutter/material.dart';

extension StatsDateRangeX on DateTimeRange {
  int get inclusiveDays => end.difference(start).inDays + 1;

  DateTimeRange shiftByDays(int days) {
    final delta = Duration(days: days);
    return DateTimeRange(start: start.add(delta), end: end.add(delta));
  }
}

extension StatsDateTimeX on DateTime {
  DateTime get dayStart => DateTime(year, month, day);

  DateTime get dayEnd => DateTime(year, month, day, 23, 59, 59, 999);
}

DateTimeRange currentIsoWeek(DateTime now) {
  final dayStart = now.dayStart;
  final monday = dayStart.subtract(
    Duration(days: dayStart.weekday - DateTime.monday),
  );
  final sunday = monday.add(const Duration(days: 6));

  return DateTimeRange(start: monday, end: sunday.dayEnd);
}
