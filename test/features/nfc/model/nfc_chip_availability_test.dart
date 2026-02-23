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
  String get nfcGuidanceDisabledBody => 'NFC is turned off on this device. Enable it in system settings to continue.';

  @override
  String get nfcGuidanceNotSupportedTitle => 'NFC is not supported';

  @override
  String get nfcGuidanceNotSupportedBody => 'This device does not support NFC scanning.';

  @override
  String get nfcGuidanceUnknownTitle => 'NFC status unavailable';

  @override
  String get nfcGuidanceUnknownBody => 'We could not determine NFC availability right now. Try again in a moment.';

  @override
  String get nfcOpenSettingsButton => 'Open settings';
  @override
  String get nfcChipConfigTitle => 'Configure NFC Tag';
  @override
  String get nfcChipConfigBody =>
      'Scan an NFC tag to link it with Pauza. You will need this tag to end your focus sessions.';
  @override
  String get nfcChipConfigLinkButton => 'Link NFC Tag';
  @override
  String get nfcChipConfigScanningButton => 'Scanning...';
  @override
  String get nfcChipConfigLinkedSuccess => 'NFC tag linked successfully.';
  @override
  String get nfcChipConfigAlreadyLinked => 'This NFC tag is already linked.';
  @override
  String get nfcChipConfigUidMissingError => 'This NFC tag cannot be linked because it does not provide an identifier.';
  @override
  String get nfcChipConfigScanFailed => 'Unable to link NFC tag. Please try again.';
  @override
  String get nfcChipConfigTagsTitle => 'Your NFC Tags';
  @override
  String get nfcChipConfigTagsBody =>
      'Manage your linked NFC tags. These tags are your physical keys to unlock focus sessions.';
  @override
  String get nfcChipConfigLinkNewTagButton => 'Link New Tag';
  @override
  String nfcChipConfigLinkedOnDate(String date) => 'Linked on $date';
  @override
  String get nfcChipConfigRenameAction => 'Rename';
  @override
  String get nfcChipConfigDeleteAction => 'Delete';
  @override
  String get nfcChipConfigRenameDialogTitle => 'Rename NFC Tag';
  @override
  String get nfcChipConfigRenameFieldLabel => 'Tag name';
  @override
  String get nfcChipConfigRenameFieldHint => 'Enter tag name';
  @override
  String get nfcChipConfigRenameSaveButton => 'Save';
  @override
  String get nfcChipConfigNoTagsTitle => 'No linked tags yet';
  @override
  String get nfcChipConfigNoTagsBody => 'Link your first NFC tag to manage focus session unlocking.';
  @override
  String get qrCodeConfigTagsTitle => 'Your QR Codes';
  @override
  String get qrCodeConfigTagsBody =>
      'Manage your linked QR codes. Open any code to preview and use it for focus session unlocking.';
  @override
  String get qrCodeConfigGenerateNewCodeButton => 'Generate New QR';
  @override
  String qrCodeConfigLinkedOnDate(String date) => 'Linked on $date';
  @override
  String get qrCodeConfigRenameAction => 'Rename';
  @override
  String get qrCodeConfigDeleteAction => 'Delete';
  @override
  String get qrCodeConfigRenameDialogTitle => 'Rename QR Code';
  @override
  String get qrCodeConfigRenameFieldLabel => 'QR code name';
  @override
  String get qrCodeConfigRenameFieldHint => 'Enter QR code name';
  @override
  String get qrCodeConfigRenameSaveButton => 'Save';
  @override
  String get qrCodeConfigNoCodesTitle => 'No linked QR codes yet';
  @override
  String get qrCodeConfigNoCodesBody => 'Generate your first QR code to manage focus session unlocking.';
  @override
  String get qrCodeConfigPreviewDialogTitle => 'QR Code Preview';
  @override
  String get qrCodeConfigPreviewDialogBody => 'Show this QR code when you need to unlock your focus session.';
  @override
  String get qrCodeConfigActionFailed => 'Unable to update QR code configuration. Please try again.';
  @override
  String get qrCodeConfigGenerateFailed => 'Unable to generate a new QR code. Please try again.';
  @override
  String get qrCodeConfigRenameFailed => 'Unable to rename QR code. Please try again.';
  @override
  String get qrCodeConfigDeleteFailed => 'Unable to delete QR code. Please try again.';
  @override
  String get readyToScanNfcTag => 'Ready to Scan';
  @override
  String get nfcChipHoldCardNearDevice => 'Hold your device near the NFC tag to scan';
  @override
  String get modeMinimumDurationTitle => 'Minimum duration';
  @override
  String get modeMinimumDurationSubtitle => 'Optional. Session can\'t be ended earlier than this.';
  @override
  String get modeMinimumDurationSetButton => 'Set duration';
  @override
  String get modeMinimumDurationClearButton => 'Clear';
  @override
  String get modeMinimumDurationNotSet => 'Not set';
  @override
  String modeMinimumDurationValueMinutes(int minutes) => '$minutes min';
  @override
  String get modeEndingPausingScenarioTitle => 'Ending / pausing scenario';
  @override
  String get modeEndingPausingScenarioSubtitle => 'Choose how this mode can be ended or paused.';
  @override
  String get modeEndingPausingScenarioNfc => 'NFC';
  @override
  String get modeEndingPausingScenarioQrCode => 'QR';
  @override
  String get modeEndingPausingScenarioManual => 'Manual';
  @override
  String get modeEndingPausingScenarioNfcDisabled => 'NFC is not supported on this device.';

  // Stub implementations for other abstract members
  @override
  String get appName => 'Pauza';
  @override
  String get authTagline => 'Focus & Wellbeing';
  @override
  String get authEmailAddress => 'Email address';
  @override
  String get authEmailHint => 'name@example.com';
  @override
  String get authPassword => 'Password';
  @override
  String get authForgotPassword => 'Forgot password?';
  @override
  String get authLogIn => 'Log in';
  @override
  String get authOtpTitle => 'Verify Your Email';
  @override
  String get authOtpSubtitlePrefix => 'Enter the 6-digit code we sent to your email address ';
  @override
  String get authOtpSubtitleSuffix => '.';
  @override
  String get authOtpVerifyButton => 'Verify';
  @override
  String get authOtpDidNotReceiveCode => "Didn't receive a code?";
  @override
  String get authOtpResendCode => 'Resend Code';
  @override
  String authOtpAvailableInLabel(String minutes, String seconds) => 'Available in $minutes:$seconds';
  @override
  String get authValidationRequired => 'This field is required';
  @override
  String get authValidationInvalidEmail => 'Enter a valid email address';
  @override
  String get authFailureInvalidCredentials => 'Invalid email or password.';
  @override
  String get authFailureInvalidOtp => 'Invalid verification code.';
  @override
  String get authFailureOtpChallengeMissing => 'Verification challenge expired. Try again.';
  @override
  String get authFailureStorage => 'Could not access secure storage.';
  @override
  String get authFailureUnknown => 'Could not sign in.';
  @override
  String get homeTitle => 'Home';
  @override
  String get statsTitle => 'Stats';
  @override
  String get leaderboardTitle => 'Leaderboard';
  @override
  String get profileTitle => 'Profile';
  @override
  String get profileDisplayNameFallback => 'Unknown User';
  @override
  String get profileUsernameFallback => 'username';
  @override
  String get profileEditInfoNavTitle => 'Edit Info';
  @override
  String get profileEditTitle => 'Edit Profile';
  @override
  String get profileEditChangePhoto => 'CHANGE PHOTO';
  @override
  String get profileEditUploadingPhoto => 'UPLOADING...';
  @override
  String get profileEditNameLabel => 'Name';
  @override
  String get profileEditNameHint => 'Your name';
  @override
  String get profileEditUsernameLabel => 'Username';
  @override
  String get profileEditUsernameHint => 'username';
  @override
  String get profileEditSaveButton => 'Save Changes';
  @override
  String get profileEditChangePhotoSheetTitle => 'Change profile photo';
  @override
  String get profileEditTakePhotoTitle => 'Take Photo';
  @override
  String get profileEditTakePhotoSubtitle => 'Use your camera to snap a new one';
  @override
  String get profileEditChooseFromGalleryTitle => 'Choose from Gallery';
  @override
  String get profileEditChooseFromGallerySubtitle => 'Pick a photo from your phone\'s library';
  @override
  String get profileEditInvalidUsernameError => 'Use 3-30 lowercase letters, digits, or underscore';
  @override
  String get profileEditUsernameTakenError => 'This username is already taken';
  @override
  String get profileEditValidationError => 'Please check your profile details';
  @override
  String get profileEditNetworkError => 'Unable to update profile. Check your connection';
  @override
  String get profileSettingsNavTitle => 'Settings';
  @override
  String get settingsTitle => 'Settings';
  @override
  String get settingsGeneralSectionTitle => 'General';
  @override
  String get settingsNotifications => 'Notifications';
  @override
  String get settingsLanguage => 'Language';
  @override
  String get settingsLanguagePickerTitle => 'Select language';
  @override
  String get settingsNfcChipConfiguring => 'NFC Chip Configuring';
  @override
  String get settingsQrCodeConfiguring => 'QR Code Configuring';
  @override
  String get settingsSignOut => 'Sign Out';
  @override
  String get settingsVersionFallback => 'Pauza';
  @override
  String settingsVersionLabel(String version) => 'Pauza v$version';
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
  String get modeIconSectionTitle => 'Icon';
  @override
  String get modeIconChooseButton => 'Choose icon';
  @override
  String get modeIconPickerTitle => 'Pick an icon';
  @override
  String get modeIconPickerSubtitle => 'Choose one icon for this mode';
  @override
  String get modeIconLabelTune => 'Tune';
  @override
  String get modeIconLabelPsychology => 'Mind';
  @override
  String get modeIconLabelTimer => 'Timer';
  @override
  String get modeIconLabelBolt => 'Bolt';
  @override
  String get modeIconLabelRocketLaunch => 'Rocket';
  @override
  String get modeIconLabelSelfImprovement => 'Calm';
  @override
  String get modeIconLabelFitnessCenter => 'Fitness';
  @override
  String get modeIconLabelSchool => 'School';
  @override
  String get modeIconLabelWork => 'Work';
  @override
  String get modeIconLabelMenuBook => 'Read';
  @override
  String get modeIconLabelMusicNote => 'Music';
  @override
  String get modeIconLabelNightlight => 'Night';
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
  String modeAllowedPausesOutOfRangeError(int min, int max) => 'Allowed pauses must be between $min and $max';
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
  @override
  String pauseDurationMinutes(num minutes) => '${minutes}m';
  @override
  String get deviceUsage => 'Device Usage';
  @override
  String get usageStatsTab => 'Usage Stats';
  @override
  String get blockingStatsTab => 'Blocking Stats';
  @override
  String get thisWeek => 'This Week';
  @override
  String get totalTime => 'Total Time';
  @override
  String get usageTrend => 'Usage Trend';
  @override
  String get statsDailyAverage => 'Daily Average';
  @override
  String get statsBucketSocial => 'Social';
  @override
  String get statsBucketProductivity => 'Productivity';
  @override
  String get statsBucketOther => 'Other';
  @override
  String get statsAppUsage => 'App Usage';
  @override
  String get statsUsageTableAppColumn => 'App';
  @override
  String get statsUsageTableUsageColumn => 'Usage';
  @override
  String get statsUsageTableLaunchesColumn => 'Launches';
  @override
  String get statsUsageTableLastUsedColumn => 'Last used';
  @override
  String statsDeltaVsLastPeriod(String value) => '$value vs last period';
  @override
  String get statsPermissionRequiredTitle => 'Usage permission required';
  @override
  String get statsPermissionRequiredBody => 'Allow usage access';
  @override
  String get statsLoadFailed => 'Failed to load usage statistics.';
  @override
  String get statsNoUsageData => 'No usage data for the selected period.';
  @override
  String get statsIosReportUnavailableTitle => 'iOS report unavailable';
  @override
  String get statsIosReportUnavailableBody => 'Ensure iOS report extension is configured.';
  @override
  String get settingsSessionEndingConfSectionTitle => 'Session Ending';

  @override
  String get pausedTakeABreathLabel => 'Take a breath';

  @override
  String get pausedTitle => 'Paused';

  @override
  String get reminaingLabel => 'Remaining';

  @override
  String get homePauseBlockedByLimit => 'Pause limit reached for this session.';

  @override
  String homeActionBlockedByMinimumDuration(String remaining) {
    return 'Action unavailable. Try again in $remaining.';
  }

  @override
  String get homeActionBlockedModeUnavailable => 'Mode data is unavailable. Please sync and try again.';

  @override
  String get scanNfcChipTitle => 'Scan NFC Tag';

  @override
  String get scanNfcTagActionLabel => 'Scan your NFC tag.';
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

      test('unknown shows guidance', () {
        expect(NfcChipAvailability.unknown.showGuidance, isTrue);
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

      test('unknown does not show open settings action', () {
        expect(NfcChipAvailability.unknown.showOpenSettingsAction, isFalse);
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

      test('unknown has warning severity', () {
        expect(NfcChipAvailability.unknown.severity, NfcAvailabilitySeverity.warning);
      });
    });

    group('shouldShowOpenSettings', () {
      test('disabled with canOpenSettings=true shows open settings action', () {
        expect(NfcChipAvailability.disabled.shouldShowOpenSettings(canOpenSettings: true), isTrue);
      });

      test('disabled with canOpenSettings=false hides open settings action', () {
        expect(NfcChipAvailability.disabled.shouldShowOpenSettings(canOpenSettings: false), isFalse);
      });

      test('other values always return false regardless of canOpenSettings', () {
        expect(NfcChipAvailability.available.shouldShowOpenSettings(canOpenSettings: true), isFalse);
        expect(NfcChipAvailability.notSupported.shouldShowOpenSettings(canOpenSettings: true), isFalse);
        expect(NfcChipAvailability.unknown.shouldShowOpenSettings(canOpenSettings: true), isFalse);
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

      test('unknown returns correct title', () {
        expect(NfcChipAvailability.unknown.localizedTitle(l10n), 'NFC status unavailable');
      });
    });

    group('localizedBody', () {
      test('available returns correct body', () {
        expect(NfcChipAvailability.available.localizedBody(l10n), 'Your device is ready to scan NFC tags.');
      });

      test('disabled returns correct body', () {
        expect(
          NfcChipAvailability.disabled.localizedBody(l10n),
          'NFC is turned off on this device. Enable it in system settings to continue.',
        );
      });

      test('notSupported returns correct body', () {
        expect(NfcChipAvailability.notSupported.localizedBody(l10n), 'This device does not support NFC scanning.');
      });

      test('unknown returns correct body', () {
        expect(
          NfcChipAvailability.unknown.localizedBody(l10n),
          'We could not determine NFC availability right now. Try again in a moment.',
        );
      });
    });

    group('localizedActionLabel', () {
      test('available returns null', () {
        expect(NfcChipAvailability.available.localizedActionLabel(l10n, canOpenSettings: true), isNull);
      });

      test('disabled with canOpenSettings=true returns action label', () {
        expect(NfcChipAvailability.disabled.localizedActionLabel(l10n, canOpenSettings: true), 'Open settings');
      });

      test('disabled with canOpenSettings=false returns null', () {
        expect(NfcChipAvailability.disabled.localizedActionLabel(l10n, canOpenSettings: false), isNull);
      });

      test('notSupported returns null', () {
        expect(NfcChipAvailability.notSupported.localizedActionLabel(l10n, canOpenSettings: true), isNull);
      });

      test('unknown returns null', () {
        expect(NfcChipAvailability.unknown.localizedActionLabel(l10n, canOpenSettings: true), isNull);
      });
    });
  });

  group('NfcAvailabilitySeverity', () {
    test('has info, warning, and error values', () {
      expect(NfcAvailabilitySeverity.values, hasLength(3));
      expect(
        NfcAvailabilitySeverity.values,
        containsAll([NfcAvailabilitySeverity.info, NfcAvailabilitySeverity.warning, NfcAvailabilitySeverity.error]),
      );
    });
  });
}
