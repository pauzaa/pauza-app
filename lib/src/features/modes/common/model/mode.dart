import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final Schedule? schedule;
  final IList<AppIdentifier> blockedAppIds;

  Mode copyWith({
    String? title,
    String? textOnScreen,
    String? description,
    int? allowedPausesCount,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    Schedule? schedule,
    IList<AppIdentifier>? blockedAppIds,
  }) => Mode(
    id: id,
    title: title ?? this.title,
    textOnScreen: textOnScreen ?? this.textOnScreen,
    description: description ?? this.description,
    allowedPausesCount: allowedPausesCount ?? this.allowedPausesCount,
    schedule: schedule ?? this.schedule,
    blockedAppIds: blockedAppIds ?? this.blockedAppIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  RestrictionMode toRestrictionMode() => RestrictionMode(
    modeId: id,
    blockedAppIds: blockedAppIds.toList(),
    schedule: schedule?.toRestrictionSchedule(),
  );

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
        days: WeekDay.decodeDays(scheduleDaysRaw),
        enabled: scheduleEnabled == 1,
        start: TimeOfDayX.fromMinutesFromMidnight(scheduleStartMinute),
        end: TimeOfDayX.fromMinutesFromMidnight(scheduleEndMinute),
      );
    }

    final blockedAppsRaw = row['blocked_apps'] as String?;
    final blockedAppIds = _parseBlockedApps(blockedAppsRaw);

    return Mode(
      id: row['id'] as String,
      title: row['title'] as String,
      textOnScreen: row['text_on_screen'] as String,
      description: row['description'] as String?,
      allowedPausesCount: row['allowed_pauses_count'] as int,
      schedule: schedule,
      blockedAppIds: blockedAppIds,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        createdAtMillis,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        updatedAtMillis,
        isUtc: true,
      ),
    );
  }

  static IList<AppIdentifier> _parseBlockedApps(String? blockedAppsRaw) {
    if (blockedAppsRaw == null || blockedAppsRaw.trim().isEmpty) {
      return const IList.empty();
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
    return ids.toIList();
  }

  @override
  String toString() =>
      'Mode(id: $id, title: $title, textOnScreen: $textOnScreen, '
      'description: $description, allowedPausesCount: $allowedPausesCount, '
      'schedule: $schedule, blockedAppIds: $blockedAppIds, createdAt: $createdAt, updatedAt: $updatedAt'
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
    schedule,
    Object.hashAllUnordered(blockedAppIds),
    createdAt,
    updatedAt,
  );
}

@immutable
class ModeUpsertDTO {
  const ModeUpsertDTO({
    required this.title,
    required this.textOnScreen,
    required this.description,
    required this.allowedPausesCount,
    required this.schedule,
    required this.blockedAppIds,
  });

  const ModeUpsertDTO.initial()
    : this(
        title: '',
        textOnScreen: '',
        description: '',
        allowedPausesCount: 0,
        schedule: const Schedule.initial(),
        blockedAppIds: const IList.empty(),
      );

  final String title;
  final String textOnScreen;
  final String? description;
  final int allowedPausesCount;
  final Schedule? schedule;
  final IList<AppIdentifier> blockedAppIds;

  ModeUpsertDTO copyWith({
    String? title,
    String? textOnScreen,
    String? description,
    int? allowedPausesCount,
    Schedule? schedule,
    IList<AppIdentifier>? blockedAppIds,
  }) => ModeUpsertDTO(
    title: title ?? this.title,
    textOnScreen: textOnScreen ?? this.textOnScreen,
    description: description ?? this.description,
    allowedPausesCount: allowedPausesCount ?? this.allowedPausesCount,
    schedule: schedule ?? this.schedule,
    blockedAppIds: blockedAppIds ?? this.blockedAppIds,
  );
}
