import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';

class _FakeAppLocalizations extends AppLocalizations {
  _FakeAppLocalizations() : super('en');

  @override
  String get nfcGuidanceAvailableTitle => 'NFC is ready';

  @override
  String get nfcGuidanceAvailableBody => 'Your device is ready to scan NFC tags.';

  @override
  String get nfcGuidanceDisabledTitle => 'Turn on NFC';

  @override
  String get nfcGuidanceDisabledBody =>
      'NFC is turned off on this device. Enable it in system settings to continue.';

  @override
  String get nfcGuidanceNotSupportedTitle => 'NFC is not supported';

  @override
  String get nfcGuidanceNotSupportedBody => 'This device does not support NFC scanning.';

  @override
  String get nfcGuidanceUnknownTitle => 'NFC status unavailable';

  @override
  String get nfcGuidanceUnknownBody =>
      'We could not determine NFC availability right now. Try again in a moment.';

  @override
  String get nfcOpenSettingsButton => 'Open settings';

  // Stub implementations for other abstract members
  @override
  String get appName => 'Pauza';
  @override
  String get homeTitle => 'Home';
  @override
  String get statsTitle => 'Stats';
  @override
  String get leaderboardTitle => 'Leaderboard';
  @override
  String get profileTitle => 'Profile';
  @override
  String get notFoundTitle => 'Page not found';
  @override
  String get confirmButton => 'Confirm';
  @override
  String get cancelButton => 'Cancel';
  @override
  String get okButton => 'OK';
  @override
  String get yesButton => 'Yes';
  @override
  String weekDaysShort(String key) => key;
  @override
  String weekDays(String key) => key;
  @override
  String get noButton => 'No';
  @override
  String get retryButton => 'Retry';
  @override
  String get closeButton => 'Close';
  @override
  String get nextButton => 'Next';
  @override
  String get previousButton => 'Previous';
  @override
  String get submitButton => 'Submit';
  @override
  String get backButton => 'Back';
  @override
  String get loadingLabel => 'Loading...';
  @override
  String get errorTitle => 'Something went wrong';
  @override
  String get successTitle => 'Success';
  @override
  String get searchPlaceholder => 'Search';
  @override
  String get emptyStateMessage => 'No items to show';
  @override
  String get startButton => 'Start';
  @override
  String get stopButton => 'Stop';
  @override
  String get selectModeTitle => 'Select mode';
  @override
  String get addModeButton => 'Add new mode';
  @override
  String get editModeButton => 'Edit';
  @override
  String get deleteModeButton => 'Delete';
  @override
  String get deleteModeTitle => 'Delete mode?';
  @override
  String get deleteModeMessage => 'This action cannot be undone.';
  @override
  String get comingSoonMessage => 'Coming soon';
  @override
  String get noModesEmptyState => 'No modes yet';
  @override
  String get selectMode => 'Select mode';
  @override
  String get alreadyBlocking => 'Already blocking';
  @override
  String get permissionUsageAccessTitle => 'Allow Usage Access';
  @override
  String get permissionUsageAccessBody => 'Usage access body';
  @override
  String get permissionAccessibilityTitle => 'Enable Accessibility Service';
  @override
  String get permissionAccessibilityBody => 'Accessibility body';
  @override
  String get permissionExactAlarmTitle => 'Allow Exact Alarms';
  @override
  String get permissionExactAlarmBody => 'Exact alarm body';
  @override
  String get permissionFamilyControlsTitle => 'Allow Family Controls';
  @override
  String get permissionFamilyControlsBody => 'Family controls body';
  @override
  String get permissionsRequiredTitle => 'Permissions Required';
  @override
  String get permissionsRequiredBody => 'Permissions body';
  @override
  String get permissionUsageAccessShortBody => 'Usage access short';
  @override
  String get permissionAccessibilityShortBody => 'Accessibility short';
  @override
  String get permissionExactAlarmShortBody => 'Exact alarm short';
  @override
  String get permissionFamilyControlsShortBody => 'Family controls short';
  @override
  String permissionCurrentStatusLabel(String status) => 'Status: $status';
  @override
  String get permissionStatusGranted => 'Granted';
  @override
  String get permissionStatusDenied => 'Denied';
  @override
  String get permissionStatusRestricted => 'Restricted';
  @override
  String get permissionStatusNotDetermined => 'Not determined';
  @override
  String get permissionOpenSettingsButton => 'Open settings';
  @override
  String get permissionAllowAccessButton => 'Allow access';
  @override
  String blockedAppsCountLabel(int count) => 'Blocked apps: $count';
  @override
  String get createModeTitle => 'Create mode';
  @override
  String get editModeTitle => 'Edit mode';
  @override
  String get modeTitleFieldLabel => 'Title';
  @override
  String get modeTextOnScreenFieldLabel => 'Text on shield screen';
  @override
  String get modeDescriptionFieldLabel => 'Description';
  @override
  String get modeEnabledLabel => 'Enabled';
  @override
  String get modeBlockedAppsSectionTitle => 'Blocked apps';
  @override
  String get modeBlockedAppsChooseButton => 'Choose apps';
  @override
  String get modeBlockedAppsSubtitle => 'Customize what to block';
  @override
  String get modeBlockedAppsSearchLabel => 'Search apps';
  @override
  String get modeBlockedAppsRequiredError => 'Select at least one app';
  @override
  String modeBlockedAppsSelectedCountLabel(int count) => 'Selected apps: $count';
  @override
  String get modeScheduleTitle => 'Schedule (Optional)';
  @override
  String get modeScheduleStartTimeLabel => 'Start time';
  @override
  String get modeScheduleEndTimeLabel => 'End time';
  @override
  String get modeScheduleDaysRequiredError => 'Select at least one day';
  @override
  String get modeStrictnessTitle => 'Strictness';
  @override
  String get modeAllowedPausesTitle => 'Allowed pauses';
  @override
  String get modeAllowedPausesSubtitle => 'Short breaks during session';
  @override
  String modeAllowedPausesOutOfRangeError(int min, int max) =>
      'Allowed pauses must be between $min and $max';
  @override
  String get modeDeleteFocusButton => 'Delete Focus Mode';
  @override
  String get modeSaveButton => 'Save Mode';
  @override
  String get modeRequiredFieldError => 'This field is required';
  @override
  String get modeLoadFailedMessage => 'Unable to load mode data';
  @override
  String get modeSaveFailedMessage => 'Unable to save mode';
  @override
  String get modeDeleteFailedMessage => 'Unable to delete mode';
  @override
  String get modeAppsLoadFailedMessage => 'Unable to load apps';
  @override
  String get saveButton => 'Save';
  @override
  String get selectAppsTitle => 'Select apps';
  @override
  String get selectAppsForPauzaTitle => 'Select Apps for Pauza';
  @override
  String get doneButton => 'Done';
  @override
  String get selectButton => 'Select';
  @override
  String appsSelectedCountLabel(int count) => '$count selected';
  @override
  String get allAppsCategory => 'All Apps';
  @override
  String get selectAllButton => 'Select all';
  @override
  String get deselectAllButton => 'Deselect all';
  @override
  String get otherAppsCategory => 'Other';
  @override
  String homeGreeting(String hour) => 'Hello';
  @override
  String get homeDashboardTitle => 'Pauza Dashboard';
  @override
  String get homePauzaSessionLabel => 'Pauza Session';
  @override
  String get homeSessionDurationLabel => 'Session Duration';
  @override
  String get homeQuickPauseLabel => 'Quick Pause';
  @override
  String get homeResumeButtonLabel => 'Resume';
  @override
  String get homeCurrentModeLabel => 'Current mode';
  @override
  String homeDayStreakLabel(int count) => '$count Day Streak';
  @override
  String homeDurationHoursMinutesLabel(int hours, int minutes) => '${hours}h ${minutes}m';
}

void main() {
  final l10n = _FakeAppLocalizations();

  group('NfcChipAvailability', () {
    group('showGuidance', () {
      test('available does not show guidance', () {
        expect(NfcChipAvailability.available.showGuidance, isFalse);
      });

      test('disabled shows guidance', () {
        expect(NfcChipAvailability.disabled.showGuidance, isTrue);
      });

      test('notSupported shows guidance', () {
        expect(NfcChipAvailability.notSupported.showGuidance, isTrue);
      });
    });

    group('showOpenSettingsAction', () {
      test('available does not show open settings action', () {
        expect(NfcChipAvailability.available.showOpenSettingsAction, isFalse);
      });

      test('disabled shows open settings action', () {
        expect(NfcChipAvailability.disabled.showOpenSettingsAction, isTrue);
      });

      test('notSupported does not show open settings action', () {
        expect(NfcChipAvailability.notSupported.showOpenSettingsAction, isFalse);
      });
    });

    group('severity', () {
      test('available has info severity', () {
        expect(NfcChipAvailability.available.severity, NfcAvailabilitySeverity.info);
      });

      test('disabled has warning severity', () {
        expect(NfcChipAvailability.disabled.severity, NfcAvailabilitySeverity.warning);
      });

      test('notSupported has error severity', () {
        expect(NfcChipAvailability.notSupported.severity, NfcAvailabilitySeverity.error);
      });
    });

    group('shouldShowOpenSettings', () {
      test('disabled with canOpenSettings=true shows open settings action', () {
        expect(NfcChipAvailability.disabled.shouldShowOpenSettings(canOpenSettings: true), isTrue);
      });

      test('disabled with canOpenSettings=false hides open settings action', () {
        expect(
          NfcChipAvailability.disabled.shouldShowOpenSettings(canOpenSettings: false),
          isFalse,
        );
      });

      test('other values always return false regardless of canOpenSettings', () {
        expect(
          NfcChipAvailability.available.shouldShowOpenSettings(canOpenSettings: true),
          isFalse,
        );
        expect(
          NfcChipAvailability.notSupported.shouldShowOpenSettings(canOpenSettings: true),
          isFalse,
        );
      });
    });

    group('localizedTitle', () {
      test('available returns correct title', () {
        expect(NfcChipAvailability.available.localizedTitle(l10n), 'NFC is ready');
      });

      test('disabled returns correct title', () {
        expect(NfcChipAvailability.disabled.localizedTitle(l10n), 'Turn on NFC');
      });

      test('notSupported returns correct title', () {
        expect(NfcChipAvailability.notSupported.localizedTitle(l10n), 'NFC is not supported');
      });
    });

    group('localizedBody', () {
      test('available returns correct body', () {
        expect(
          NfcChipAvailability.available.localizedBody(l10n),
          'Your device is ready to scan NFC tags.',
        );
      });

      test('disabled returns correct body', () {
        expect(
          NfcChipAvailability.disabled.localizedBody(l10n),
          'NFC is turned off on this device. Enable it in system settings to continue.',
        );
      });

      test('notSupported returns correct body', () {
        expect(
          NfcChipAvailability.notSupported.localizedBody(l10n),
          'This device does not support NFC scanning.',
        );
      });
    });

    group('localizedActionLabel', () {
      test('available returns null', () {
        expect(
          NfcChipAvailability.available.localizedActionLabel(l10n, canOpenSettings: true),
          isNull,
        );
      });

      test('disabled with canOpenSettings=true returns action label', () {
        expect(
          NfcChipAvailability.disabled.localizedActionLabel(l10n, canOpenSettings: true),
          'Open settings',
        );
      });

      test('disabled with canOpenSettings=false returns null', () {
        expect(
          NfcChipAvailability.disabled.localizedActionLabel(l10n, canOpenSettings: false),
          isNull,
        );
      });

      test('notSupported returns null', () {
        expect(
          NfcChipAvailability.notSupported.localizedActionLabel(l10n, canOpenSettings: true),
          isNull,
        );
      });
    });
  });

  group('NfcAvailabilitySeverity', () {
    test('has info, warning, and error values', () {
      expect(NfcAvailabilitySeverity.values, hasLength(3));
      expect(
        NfcAvailabilitySeverity.values,
        containsAll([
          NfcAvailabilitySeverity.info,
          NfcAvailabilitySeverity.warning,
          NfcAvailabilitySeverity.error,
        ]),
      );
    });
  });
}
