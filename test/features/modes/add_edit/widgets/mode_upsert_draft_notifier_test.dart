import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_upsert_draft_notifier.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/modes/common/model/schedule.dart';
import 'package:pauza/src/features/modes/common/model/week_day.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ModeUpsertDraftNotifier', () {
    test('validateForSubmit returns required field errors', () {
      final notifier = ModeUpsertDraftNotifier(hasNfcSupport: true);

      final result = notifier.validateForSubmit();

      expect(result.isValid, isFalse);
      expect(result[ModeUpsertValidationField.title], ModeUpsertValidationCode.required);
      expect(result[ModeUpsertValidationField.textOnScreen], ModeUpsertValidationCode.required);
      expect(result[ModeUpsertValidationField.blockedApps], ModeUpsertValidationCode.blockedAppsRequired);
    });

    test('schedule enabled requires selected days', () {
      final notifier = ModeUpsertDraftNotifier(hasNfcSupport: true)
        ..updateTitle('Deep Work')
        ..updateTextOnScreen('Stay focused')
        ..updateBlockedApps(ISet(const [AppIdentifier('app.one')]))
        ..toggleScheduleEnabled(true);

      final result = notifier.validateForSubmit();

      expect(result.isValid, isFalse);
      expect(result[ModeUpsertValidationField.scheduleDays], ModeUpsertValidationCode.scheduleDaysRequired);
    });

    test('create mode stores null schedule when disabled', () {
      final notifier = ModeUpsertDraftNotifier(hasNfcSupport: true)
        ..configureForMode(initialDraft: const ModeUpsertDTO.initialForDevice(hasNfcSupport: true), isEditMode: false)
        ..toggleScheduleEnabled(true)
        ..toggleScheduleDay(WeekDay.mon)
        ..toggleScheduleEnabled(false);

      final request = notifier.buildSubmitRequest();

      expect(request.schedule, isNull);
    });

    test('edit mode keeps schedule object disabled when it existed initially', () {
      final notifier = ModeUpsertDraftNotifier(hasNfcSupport: true)
        ..configureForMode(
          isEditMode: true,
          initialDraft: makeModeUpsertDto(
            title: 'Focus',
            allowedPausesCount: 2,
            blockedAppIds: ISet<AppIdentifier>(const <AppIdentifier>[AppIdentifier('app.one')]),
            schedule: Schedule(
              days: ISet<WeekDay>(const [WeekDay.mon]),
              start: const TimeOfDay(hour: 9, minute: 0),
              end: const TimeOfDay(hour: 17, minute: 0),
              enabled: true,
            ),
          ),
        )
        ..toggleScheduleEnabled(false);

      final request = notifier.buildSubmitRequest();

      expect(request.schedule, isNotNull);
      expect(request.schedule?.enabled, isFalse);
      expect(request.schedule?.days, isNotEmpty);
    });

    test('allowed pauses are clamped to 0..5', () {
      final notifier = ModeUpsertDraftNotifier(hasNfcSupport: true);

      for (var i = 0; i < 10; i++) {
        notifier.incrementPauses();
      }
      expect(notifier.value.allowedPausesCount, 5);

      for (var i = 0; i < 10; i++) {
        notifier.decrementPauses();
      }
      expect(notifier.value.allowedPausesCount, 0);
    });

    test('initial draft uses default icon', () {
      final notifier = ModeUpsertDraftNotifier(hasNfcSupport: true);

      expect(notifier.value.icon, ModeIconCatalog.defaultIcon);
    });

    test('updateIcon normalizes invalid token to default', () {
      final notifier = ModeUpsertDraftNotifier(hasNfcSupport: true);

      notifier.updateIcon(ModeIcon.fromToken('invalid'));

      expect(notifier.value.icon, ModeIconCatalog.defaultIcon);
    });

    test('updateMinimumDuration sets and clears value', () {
      final notifier = ModeUpsertDraftNotifier(hasNfcSupport: true);

      notifier.updateMinimumDuration(const Duration(minutes: 15));
      expect(notifier.value.minimumDuration, const Duration(minutes: 15));

      notifier.updateMinimumDuration(null);
      expect(notifier.value.minimumDuration, isNull);
    });

    test('fallbacks to qr scenario when nfc support is unavailable', () {
      final notifier = ModeUpsertDraftNotifier(hasNfcSupport: false);

      notifier.updateEndingPausingScenario(ModeEndingPausingScenario.nfc);

      expect(notifier.value.endingPausingScenario, ModeEndingPausingScenario.qrCode);
    });
  });
}
