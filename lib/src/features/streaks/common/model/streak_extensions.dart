extension StreakObjectX on Object? {
  int get intOrZero {
    return switch (this) {
      final int number => number,
      final num number => number.toInt(),
      _ => 0,
    };
  }
}

extension StreakLocalDayDateTimeX on DateTime {
  String get localDayKey {
    final local = isUtc ? toLocal() : this;
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

extension StreakLocalDayStringX on String {
  DateTime? get localDayDate {
    final parts = split('-');
    if (parts.length != 3) {
      return null;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }

    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }

    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }

    return parsed;
  }
}
