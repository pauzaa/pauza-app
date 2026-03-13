import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';
import 'package:pauza/src/features/ai/common/model/ai_focus_session_dto.dart';

@immutable
final class DailyReportRequestDto extends Equatable {
  const DailyReportRequestDto({
    required this.date,
    required this.appUsage,
    this.focusSessions,
    this.totalScreenTimeMs,
    this.totalUnlocks,
    this.streakDays,
  });

  /// Date in `YYYY-MM-DD` format.
  final String date;

  final IList<AiAppUsageItemDto> appUsage;
  final IList<AiFocusSessionDto>? focusSessions;
  final int? totalScreenTimeMs;
  final int? totalUnlocks;
  final int? streakDays;

  Map<String, Object?> toJson() => <String, Object?>{
    'date': date,
    'app_usage': appUsage.map((e) => e.toJson()).toList(growable: false),
    if (focusSessions != null)
      'focus_sessions':
          focusSessions!.map((e) => e.toJson()).toList(growable: false),
    if (totalScreenTimeMs != null) 'total_screen_time_ms': totalScreenTimeMs,
    if (totalUnlocks != null) 'total_unlocks': totalUnlocks,
    if (streakDays != null) 'streak_days': streakDays,
  };

  @override
  List<Object?> get props => <Object?>[
    date,
    appUsage,
    focusSessions,
    totalScreenTimeMs,
    totalUnlocks,
    streakDays,
  ];

  @override
  String toString() =>
      'DailyReportRequestDto($date, apps: ${appUsage.length})';
}
