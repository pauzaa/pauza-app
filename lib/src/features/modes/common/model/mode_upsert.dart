import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/schedule.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

@immutable
class ModeUpsertDTO {
  const ModeUpsertDTO({
    required this.title,
    required this.textOnScreen,
    required this.description,
    required this.allowedPausesCount,
    required this.icon,
    required this.schedule,
    required this.blockedAppIds,
  });

  const ModeUpsertDTO.initial()
    : this(
        title: '',
        textOnScreen: '',
        description: '',
        allowedPausesCount: 0,
        icon: ModeIconCatalog.defaultIcon,
        schedule: null,
        blockedAppIds: const ISet<AppIdentifier>.empty(),
      );

  final String title;
  final String textOnScreen;
  final String? description;
  final int allowedPausesCount;
  final ModeIcon icon;
  final Schedule? schedule;
  final ISet<AppIdentifier> blockedAppIds;

  ModeUpsertDTO copyWith({
    String? title,
    String? textOnScreen,
    String? description,
    int? allowedPausesCount,
    ModeIcon? icon,
    Schedule? schedule,
    ISet<AppIdentifier>? blockedAppIds,
  }) => ModeUpsertDTO(
    title: title ?? this.title,
    textOnScreen: textOnScreen ?? this.textOnScreen,
    description: description ?? this.description,
    allowedPausesCount: allowedPausesCount ?? this.allowedPausesCount,
    icon: icon ?? this.icon,
    schedule: schedule ?? this.schedule,
    blockedAppIds: blockedAppIds ?? this.blockedAppIds,
  );
}

enum ModeUpsertValidationField {
  title,
  textOnScreen,
  blockedApps,
  allowedPausesCount,
  scheduleDays,
}

enum ModeUpsertValidationCode {
  required,
  blockedAppsRequired,
  allowedPausesOutOfRange,
  scheduleDaysRequired,
}

@immutable
class ModeUpsertValidationResult {
  const ModeUpsertValidationResult({required this.fieldErrors});

  const ModeUpsertValidationResult.valid()
    : fieldErrors = const IMap<ModeUpsertValidationField, ModeUpsertValidationCode>.empty();

  final IMap<ModeUpsertValidationField, ModeUpsertValidationCode> fieldErrors;

  bool get isValid => fieldErrors.isEmpty;

  ModeUpsertValidationCode? operator [](ModeUpsertValidationField field) => fieldErrors[field];
}
