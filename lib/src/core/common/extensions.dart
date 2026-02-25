import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart' show DateTimeX;

extension IterableX<A> on Iterable<A> {
  /// Inserts [element] between elements of this [Iterable].
  Iterable<A> interleaved(A element) sync* {
    var index = 0;
    for (final current in this) {
      yield current;
      if (index++ != length - 1) yield element;
    }
  }
}

extension DateTimeX on DateTime {
  String formatLinkedDate(BuildContext context) {
    final localeName = Localizations.localeOf(context).toLanguageTag();
    return DateFormat('MMM dd, yyyy', localeName).format(toLocal());
  }

  DateTimeRange get thisWeek {
    final dayStart = this.dayStart;
    final monday = dayStart.subtract(Duration(days: dayStart.weekday - DateTime.monday));
    final sunday = monday.add(const Duration(days: 6));

    return DateTimeRange(start: monday, end: sunday.dayEnd);
  }

  DateTimeRange get pastWeek {
    final dayStart = this.dayStart;
    final startDate = dayStart.subtract(const Duration(days: 6));
    final endDate = dayStart;

    return DateTimeRange(start: startDate, end: endDate);
  }
}

extension DurationNX on Duration? {
  String formatDurationLabel(AppLocalizations localizations) {
    final duration = this;
    if (duration == null) {
      return '--';
    }
    if (duration > Duration.zero && duration < const Duration(minutes: 1)) {
      return localizations.statsDurationLessThanMinute;
    }
    final totalMinutes = duration.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return localizations.homeDurationHoursMinutesLabel(hours, minutes);
  }
}

extension DurationX on Duration {
  String formatTimerHhMmSs() {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
