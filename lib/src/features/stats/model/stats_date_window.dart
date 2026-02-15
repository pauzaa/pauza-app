import 'package:flutter/material.dart';

@immutable
class StatsDateWindow {
  const StatsDateWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  int get inclusiveDays => end.difference(start).inDays + 1;

  DateTimeRange get asDateTimeRange => DateTimeRange(start: start, end: end);

  StatsDateWindow shiftByDays(int days) {
    final delta = Duration(days: days);
    return StatsDateWindow(start: start.add(delta), end: end.add(delta));
  }

  static StatsDateWindow currentIsoWeek(DateTime now) {
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayOfWeek = dayStart.weekday;
    final monday = dayStart.subtract(
      Duration(days: dayOfWeek - DateTime.monday),
    );
    final sunday = monday.add(const Duration(days: 6));
    return StatsDateWindow(start: monday, end: _atDayEnd(sunday));
  }

  static DateTime atDayStart(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime atDayEnd(DateTime value) => _atDayEnd(value);

  static DateTime _atDayEnd(DateTime value) =>
      DateTime(value.year, value.month, value.day, 23, 59, 59, 999);

  @override
  String toString() => 'StatsDateWindow(start: $start, end: $end)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StatsDateWindow && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}
