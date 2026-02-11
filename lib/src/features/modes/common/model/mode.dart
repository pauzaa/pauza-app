import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/modes/common/model/schedule.dart';
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
  final List<AppIdentifier> blockedAppIds;

  Mode copyWith({
    String? title,
    String? textOnScreen,
    String? description,
    int? allowedPausesCount,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    Schedule? schedule,
    List<AppIdentifier>? blockedAppIds,
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
    blockedAppIds: blockedAppIds,
    schedule: schedule?.toRestrictionSchedule(),
  );

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
        blockedAppIds: const [],
      );

  final String title;
  final String textOnScreen;
  final String? description;
  final int allowedPausesCount;
  final Schedule? schedule;
  final List<AppIdentifier> blockedAppIds;

  ModeUpsertDTO copyWith({
    String? title,
    String? textOnScreen,
    String? description,
    int? allowedPausesCount,
    Schedule? schedule,
    List<AppIdentifier>? blockedAppIds,
  }) => ModeUpsertDTO(
    title: title ?? this.title,
    textOnScreen: textOnScreen ?? this.textOnScreen,
    description: description ?? this.description,
    allowedPausesCount: allowedPausesCount ?? this.allowedPausesCount,
    schedule: schedule ?? this.schedule,
    blockedAppIds: blockedAppIds ?? this.blockedAppIds,
  );
}
