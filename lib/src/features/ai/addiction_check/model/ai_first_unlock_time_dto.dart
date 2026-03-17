import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class AiFirstUnlockTimeDto extends Equatable {
  const AiFirstUnlockTimeDto({required this.date, required this.timeOfDayMinute});

  /// Date in `YYYY-MM-DD` format.
  final String date;

  /// Minute-of-day of first unlock (0-1439).
  final int timeOfDayMinute;

  Map<String, Object?> toJson() => <String, Object?>{'date': date, 'time_of_day_minute': timeOfDayMinute};

  @override
  List<Object?> get props => <Object?>[date, timeOfDayMinute];

  @override
  String toString() => 'AiFirstUnlockTimeDto($date, minute: $timeOfDayMinute)';
}
