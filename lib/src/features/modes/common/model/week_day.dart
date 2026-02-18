import 'package:collection/collection.dart';
import 'package:pauza/src/core/localization/l10n.dart';

enum WeekDay implements Localizable {
  mon(1),
  tue(2),
  wed(3),
  thu(4),
  fri(5),
  sat(6),
  sun(7);

  const WeekDay(this.dayIndex);

  factory WeekDay.fromDateTime(DateTime dateTime) => WeekDay.values.firstWhere((day) => day.dayIndex == dateTime.weekday);

  factory WeekDay.fromDayIndex(int dayIndex) => WeekDay.values.firstWhere((day) => day.dayIndex == dayIndex);

  final int dayIndex;

  @override
  String localize(AppLocalizations localizations) => localizations.weekDays(name);

  String localizeShort(AppLocalizations localizations) => localizations.weekDaysShort(name);

  /// return closes date time within one week
  DateTime get closestDateTime {
    final now = DateTime.now();
    final daysUntil = daysUntill(now);
    return now.add(Duration(days: daysUntil));
  }

  int daysUntill(DateTime now) {
    final diff = dayIndex - now.weekday;
    return diff >= 0 ? diff : 7 + diff;
  }

  static List<WeekDay> get weekDaysSortedFromToday {
    final now = DateTime.now();
    final sortedDays = List<WeekDay>.from(WeekDay.values).sorted((a, b) => a.daysUntill(now).compareTo(b.daysUntill(now)));
    return sortedDays;
  }

  static String encodeDays(Iterable<WeekDay> days) {
    if (days.isEmpty) {
      return '';
    }
    return days.map((day) => day.dayIndex).join(',');
  }

  static List<WeekDay> decodeDays(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    final values = raw.split(',');
    final parsedDays = <WeekDay>[];
    for (final value in values) {
      if (int.tryParse(value.trim()) case final parsed? when parsed < 1 || parsed > 7) {
        parsedDays.add(WeekDay.fromDayIndex(parsed));
      }
    }
    return parsedDays;
  }
}
