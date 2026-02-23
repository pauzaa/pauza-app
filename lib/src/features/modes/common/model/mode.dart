import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/schedule.dart';
import 'package:pauza/src/features/modes/common/model/week_day.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

@immutable
class Mode {
  const Mode({
    required this.id,
    required this.title,
    required this.textOnScreen,
    required this.description,
    required this.allowedPausesCount,
    required this.minimumDuration,
    required this.endingPausingScenario,
    required this.icon,
    required this.schedule,
    required this.blockedAppIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String textOnScreen;
  final String? description;
  final int allowedPausesCount;
  final Duration? minimumDuration;
  final ModeEndingPausingScenario endingPausingScenario;
  final ModeIcon icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Schedule? schedule;
  final ISet<AppIdentifier> blockedAppIds;

  Mode copyWith({
    String? title,
    String? textOnScreen,
    String? description,
    int? allowedPausesCount,
    Duration? minimumDuration,
    ModeEndingPausingScenario? endingPausingScenario,
    ModeIcon? icon,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    Schedule? schedule,
    ISet<AppIdentifier>? blockedAppIds,
  }) => Mode(
    id: id,
    title: title ?? this.title,
    textOnScreen: textOnScreen ?? this.textOnScreen,
    description: description ?? this.description,
    allowedPausesCount: allowedPausesCount ?? this.allowedPausesCount,
    minimumDuration: minimumDuration ?? this.minimumDuration,
    endingPausingScenario: endingPausingScenario ?? this.endingPausingScenario,
    icon: icon ?? this.icon,
    schedule: schedule ?? this.schedule,
    blockedAppIds: blockedAppIds ?? this.blockedAppIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  RestrictionMode toRestrictionMode() =>
      RestrictionMode(modeId: id, blockedAppIds: blockedAppIds.toList(), schedule: schedule?.toRestrictionSchedule());

  factory Mode.fromDbRow(Map<String, Object?> row) {
    final createdAtMillis = row['created_at'] as int;
    final updatedAtMillis = row['updated_at'] as int;

    final scheduleDaysRaw = row['schedule_days'] as String?;
    final scheduleStartMinute = row['schedule_start_minute'] as int?;
    final scheduleEndMinute = row['schedule_end_minute'] as int?;
    final scheduleEnabled = row['schedule_enabled'] as int?;

    Schedule? schedule;
    if (scheduleDaysRaw != null &&
        scheduleStartMinute != null &&
        scheduleEndMinute != null &&
        scheduleEnabled != null) {
      schedule = Schedule(
        days: WeekDay.decodeDays(scheduleDaysRaw).toISet(),
        enabled: scheduleEnabled == 1,
        start: TimeOfDayX.fromMinutesFromMidnight(scheduleStartMinute),
        end: TimeOfDayX.fromMinutesFromMidnight(scheduleEndMinute),
      );
    }

    final blockedAppsRaw = row['blocked_apps'] as String?;
    final blockedAppIds = _parseBlockedApps(blockedAppsRaw);
    final rawIconToken = row['icon_token'] as String?;
    final minimumDurationMilliseconds = row['minimum_duration_ms'] as int?;
    final endingPausingScenario = ModeEndingPausingScenario.fromDbValue(row['ending_pausing_scenario'] as String?);

    return Mode(
      id: row['id'] as String,
      title: row['title'] as String,
      textOnScreen: row['text_on_screen'] as String,
      description: row['description'] as String?,
      allowedPausesCount: row['allowed_pauses_count'] as int,
      minimumDuration: minimumDurationMilliseconds == null ? null : Duration(milliseconds: minimumDurationMilliseconds),
      endingPausingScenario: endingPausingScenario,
      icon: ModeIcon.fromToken(ModeIconCatalog.normalizeToken(rawIconToken)),
      schedule: schedule,
      blockedAppIds: blockedAppIds,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMillis, isUtc: true),
    );
  }

  static ISet<AppIdentifier> _parseBlockedApps(String? blockedAppsRaw) {
    if (blockedAppsRaw == null || blockedAppsRaw.trim().isEmpty) {
      return const ISet.empty();
    }
    final parts = blockedAppsRaw.split(',');
    final ids = <AppIdentifier>[];
    for (final part in parts) {
      final value = part.trim();
      if (value.isEmpty) {
        continue;
      }
      ids.add(AppIdentifier(value));
    }
    return ids.toISet();
  }

  @override
  String toString() =>
      'Mode(id: $id, title: $title, textOnScreen: $textOnScreen, '
      'description: $description, allowedPausesCount: $allowedPausesCount, '
      'minimumDuration: $minimumDuration, endingPausingScenario: $endingPausingScenario, '
      'icon: $icon, schedule: $schedule, blockedAppIds: $blockedAppIds, '
      'createdAt: $createdAt, updatedAt: $updatedAt'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          textOnScreen == other.textOnScreen &&
          description == other.description &&
          allowedPausesCount == other.allowedPausesCount &&
          minimumDuration == other.minimumDuration &&
          endingPausingScenario == other.endingPausingScenario &&
          icon == other.icon &&
          schedule == other.schedule &&
          blockedAppIds == other.blockedAppIds &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    textOnScreen,
    description,
    allowedPausesCount,
    minimumDuration,
    endingPausingScenario,
    icon,
    schedule,
    Object.hashAllUnordered(blockedAppIds),
    createdAt,
    updatedAt,
  );
}
