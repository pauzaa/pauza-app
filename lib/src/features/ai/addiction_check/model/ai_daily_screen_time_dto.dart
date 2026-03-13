import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class AiDailyScreenTimeDto extends Equatable {
  const AiDailyScreenTimeDto({
    required this.date,
    required this.totalScreenTimeMs,
    required this.totalUnlocks,
  });

  /// Date in `YYYY-MM-DD` format.
  final String date;

  final int totalScreenTimeMs;
  final int totalUnlocks;

  Map<String, Object?> toJson() => <String, Object?>{
    'date': date,
    'total_screen_time_ms': totalScreenTimeMs,
    'total_unlocks': totalUnlocks,
  };

  @override
  List<Object?> get props => <Object?>[date, totalScreenTimeMs, totalUnlocks];

  @override
  String toString() =>
      'AiDailyScreenTimeDto($date, '
      'screen: ${totalScreenTimeMs}ms, '
      'unlocks: $totalUnlocks)';
}
