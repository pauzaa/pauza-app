import 'package:pauza/src/core/common/local_day_extensions.dart';

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
