import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
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
    required this.minimumDuration,
    required this.endingPausingScenario,
    required this.icon,
    required this.schedule,
    required this.blockedAppIds,
  });

  const ModeUpsertDTO.initialForDevice({required bool hasNfcSupport})
    : this(
        title: '',
        textOnScreen: '',
        description: '',
        allowedPausesCount: 0,
        minimumDuration: null,
        endingPausingScenario: hasNfcSupport ? ModeEndingPausingScenario.nfc : ModeEndingPausingScenario.qrCode,
        icon: ModeIconCatalog.defaultIcon,
        schedule: null,
        blockedAppIds: const ISet<AppIdentifier>.empty(),
      );

  final String title;
  final String textOnScreen;
  final String? description;
  final int allowedPausesCount;
  final Duration? minimumDuration;
  final ModeEndingPausingScenario endingPausingScenario;
  final ModeIcon icon;
  final Schedule? schedule;
  final ISet<AppIdentifier> blockedAppIds;

  RestrictionMode toRestrictionMode({required String modeId}) {
    final restrictionSchedule = switch (schedule) {
      final schedule? when schedule.enabled => schedule.toRestrictionSchedule(),
      _ => null,
    };

    return RestrictionMode(modeId: modeId, blockedAppIds: blockedAppIds.toList(), schedule: restrictionSchedule);
  }

  ModeUpsertDTO copyWith({
    String? title,
    String? textOnScreen,
    String? description,
    int? allowedPausesCount,
    Duration? minimumDuration,
    ModeEndingPausingScenario? endingPausingScenario,
    ModeIcon? icon,
    Schedule? schedule,
    ISet<AppIdentifier>? blockedAppIds,
    bool clearMinimumDuration = false,
  }) => ModeUpsertDTO(
    title: title ?? this.title,
    textOnScreen: textOnScreen ?? this.textOnScreen,
    description: description ?? this.description,
    allowedPausesCount: allowedPausesCount ?? this.allowedPausesCount,
    minimumDuration: clearMinimumDuration ? null : minimumDuration ?? this.minimumDuration,
    endingPausingScenario: endingPausingScenario ?? this.endingPausingScenario,
    icon: icon ?? this.icon,
    schedule: schedule ?? this.schedule,
    blockedAppIds: blockedAppIds ?? this.blockedAppIds,
  );
}

enum ModeUpsertValidationField { title, textOnScreen, blockedApps, allowedPausesCount, scheduleDays }

enum ModeUpsertValidationCode { required, blockedAppsRequired, allowedPausesOutOfRange, scheduleDaysRequired }

@immutable
class ModeUpsertValidationResult {
  const ModeUpsertValidationResult({required this.fieldErrors});

  const ModeUpsertValidationResult.valid()
    : fieldErrors = const IMap<ModeUpsertValidationField, ModeUpsertValidationCode>.empty();

  final IMap<ModeUpsertValidationField, ModeUpsertValidationCode> fieldErrors;

  bool get isValid => fieldErrors.isEmpty;

  ModeUpsertValidationCode? operator [](ModeUpsertValidationField field) => fieldErrors[field];
}
