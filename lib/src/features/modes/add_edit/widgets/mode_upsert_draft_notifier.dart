import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/modes/common/model/schedule.dart';
import 'package:pauza/src/features/modes/common/model/week_day.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

class ModeUpsertDraftNotifier extends ValueNotifier<ModeUpsertDTO> {
  ModeUpsertDraftNotifier() : super(const ModeUpsertDTO.initial());

  static const int minAllowedPauses = 0;
  static const int maxAllowedPauses = 5;

  int _revision = 0;
  bool _isEditMode = false;
  bool _hadInitialSchedule = false;
  bool _submitted = false;
  ModeUpsertValidationResult _validation =
      const ModeUpsertValidationResult.valid();

  int get revision => _revision;
  bool get isEditMode => _isEditMode;
  bool get hadInitialSchedule => _hadInitialSchedule;
  ModeUpsertValidationResult get validation => _validation;

  void update(ModeUpsertDTO Function(ModeUpsertDTO current) updater) {
    value = updater(value);
    if (_submitted) {
      _validation = _validateDraft(value);
    }
  }

  void configureForMode({
    required ModeUpsertDTO initialDraft,
    required bool isEditMode,
  }) {
    _isEditMode = isEditMode;
    _hadInitialSchedule = initialDraft.schedule != null;
    replace(initialDraft);
  }

  void replace(ModeUpsertDTO request, {bool resetValidation = true}) {
    _revision++;
    value = request;
    if (resetValidation) {
      _submitted = false;
      _validation = const ModeUpsertValidationResult.valid();
    }
  }

  void updateTitle(String title) {
    update((current) => current.copyWith(title: title));
  }

  void updateTextOnScreen(String textOnScreen) {
    update((current) => current.copyWith(textOnScreen: textOnScreen));
  }

  void updateDescription(String description) {
    update((current) => current.copyWith(description: description));
  }

  void updateBlockedApps(ISet<AppIdentifier> blockedAppIds) {
    update(
      (current) => current.copyWith(blockedAppIds: blockedAppIds.toISet()),
    );
  }

  void incrementPauses() {
    update(
      (current) => current.copyWith(
        allowedPausesCount: (current.allowedPausesCount + 1).clamp(
          minAllowedPauses,
          maxAllowedPauses,
        ),
      ),
    );
  }

  void decrementPauses() {
    update(
      (current) => current.copyWith(
        allowedPausesCount: (current.allowedPausesCount - 1).clamp(
          minAllowedPauses,
          maxAllowedPauses,
        ),
      ),
    );
  }

  void toggleScheduleEnabled(bool enabled) {
    final current = value;
    final schedule = current.schedule;
    if (enabled) {
      final baseSchedule = schedule ?? const Schedule.initial();
      update(
        (draft) => draft.copyWith(
          schedule: Schedule(
            days: baseSchedule.days,
            start: baseSchedule.start,
            end: baseSchedule.end,
            enabled: true,
          ),
        ),
      );
      return;
    }

    if (_isEditMode && _hadInitialSchedule) {
      final baseSchedule = schedule ?? const Schedule.initial();
      update(
        (draft) => draft.copyWith(
          schedule: Schedule(
            days: baseSchedule.days,
            start: baseSchedule.start,
            end: baseSchedule.end,
            enabled: false,
          ),
        ),
      );
      return;
    }

    update((draft) => _copyWithSchedule(draft: draft, schedule: null));
  }

  void toggleScheduleDay(WeekDay day) {
    final schedule = value.schedule ?? const Schedule.initial();
    var days = schedule.days;
    if (days.contains(day)) {
      days = days.remove(day);
    } else {
      days = days.add(day);
    }

    update((draft) => draft.copyWith(schedule: schedule.copyWith(days: days)));
  }

  void updateScheduleStart(TimeOfDay start) {
    final schedule = value.schedule ?? const Schedule.initial();
    update(
      (draft) => draft.copyWith(schedule: schedule.copyWith(start: start)),
    );
  }

  void updateScheduleEnd(TimeOfDay end) {
    final schedule = value.schedule ?? const Schedule.initial();
    update((draft) => draft.copyWith(schedule: schedule.copyWith(end: end)));
  }

  ModeUpsertValidationResult validateForSubmit() {
    _submitted = true;
    _validation = _validateDraft(value);
    notifyListeners();
    return _validation;
  }

  ModeUpsertDTO buildSubmitRequest() {
    final current = value;
    final normalizedSchedule = _normalizedSchedule(current.schedule);
    return ModeUpsertDTO(
      title: current.title.trim(),
      textOnScreen: current.textOnScreen.trim(),
      description: current.description?.trim(),
      allowedPausesCount: current.allowedPausesCount,
      schedule: normalizedSchedule,
      blockedAppIds: current.blockedAppIds,
    );
  }

  ModeUpsertValidationResult _validateDraft(ModeUpsertDTO draft) {
    final errors = <ModeUpsertValidationField, ModeUpsertValidationCode>{};

    if (draft.title.trim().isEmpty) {
      errors[ModeUpsertValidationField.title] =
          ModeUpsertValidationCode.required;
    }
    if (draft.textOnScreen.trim().isEmpty) {
      errors[ModeUpsertValidationField.textOnScreen] =
          ModeUpsertValidationCode.required;
    }
    if (draft.blockedAppIds.isEmpty) {
      errors[ModeUpsertValidationField.blockedApps] =
          ModeUpsertValidationCode.blockedAppsRequired;
    }
    if (draft.allowedPausesCount < minAllowedPauses ||
        draft.allowedPausesCount > maxAllowedPauses) {
      errors[ModeUpsertValidationField.allowedPausesCount] =
          ModeUpsertValidationCode.allowedPausesOutOfRange;
    }

    final schedule = draft.schedule;
    if (schedule != null && schedule.enabled && schedule.days.isEmpty) {
      errors[ModeUpsertValidationField.scheduleDays] =
          ModeUpsertValidationCode.scheduleDaysRequired;
    }

    return ModeUpsertValidationResult(fieldErrors: errors.toIMap());
  }

  Schedule? _normalizedSchedule(Schedule? schedule) {
    if (schedule == null) {
      return null;
    }
    if (schedule.enabled) {
      return Schedule(
        days: schedule.days,
        start: schedule.start,
        end: schedule.end,
        enabled: true,
      );
    }

    if (_isEditMode && _hadInitialSchedule) {
      return Schedule(
        days: schedule.days,
        start: schedule.start,
        end: schedule.end,
        enabled: false,
      );
    }

    return null;
  }

  ModeUpsertDTO _copyWithSchedule({
    required ModeUpsertDTO draft,
    required Schedule? schedule,
  }) {
    return ModeUpsertDTO(
      title: draft.title,
      textOnScreen: draft.textOnScreen,
      description: draft.description,
      allowedPausesCount: draft.allowedPausesCount,
      blockedAppIds: draft.blockedAppIds,
      schedule: schedule,
    );
  }
}

class ModeUpsertScope extends InheritedNotifier<ModeUpsertDraftNotifier> {
  const ModeUpsertScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static ModeUpsertDraftNotifier watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ModeUpsertScope>();
    assert(scope != null, 'Mode upsert scope is missing in widget tree.');
    return scope!.notifier!;
  }
}
