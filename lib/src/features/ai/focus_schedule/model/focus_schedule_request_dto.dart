import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';
import 'package:pauza/src/features/ai/focus_schedule/model/ai_current_schedule_dto.dart';

@immutable
final class FocusScheduleRequestDto extends Equatable {
  const FocusScheduleRequestDto({
    required this.appUsage,
    required this.preferredFocusHours,
    required this.timezone,
    this.currentSchedules,
  });

  final IList<AiAppUsageItemDto> appUsage;

  /// Desired daily focus hours (1-16).
  final int preferredFocusHours;

  /// IANA timezone, e.g. `'Asia/Almaty'`.
  final String timezone;

  final IList<AiCurrentScheduleDto>? currentSchedules;

  Map<String, Object?> toJson() => <String, Object?>{
    'app_usage': appUsage.map((e) => e.toJson()).toList(growable: false),
    'preferred_focus_hours': preferredFocusHours,
    'timezone': timezone,
    if (currentSchedules != null)
      'current_schedules':
          currentSchedules!.map((e) => e.toJson()).toList(growable: false),
  };

  @override
  List<Object?> get props => <Object?>[
    appUsage,
    preferredFocusHours,
    timezone,
    currentSchedules,
  ];

  @override
  String toString() =>
      'FocusScheduleRequestDto('
      'apps: ${appUsage.length}, '
      'hours: $preferredFocusHours, '
      'tz: $timezone)';
}
