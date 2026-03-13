import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';

@immutable
final class AiCurrentScheduleDto extends Equatable {
  const AiCurrentScheduleDto({
    required this.days,
    required this.startMinute,
    required this.endMinute,
  });

  /// Day-of-week numbers.
  final IList<int> days;

  /// Start time as minute-of-day (0-1439).
  final int startMinute;

  /// End time as minute-of-day (0-1439).
  final int endMinute;

  Map<String, Object?> toJson() => <String, Object?>{
    'days': days.toList(growable: false),
    'start_minute': startMinute,
    'end_minute': endMinute,
  };

  @override
  List<Object?> get props => <Object?>[days, startMinute, endMinute];

  @override
  String toString() =>
      'AiCurrentScheduleDto(days: $days, $startMinute-$endMinute)';
}
