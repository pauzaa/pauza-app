// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get settingsSessionEndingConfSectionTitle => 'Session Ending';

  @override
  String get scanNfcChipTitle => 'Scan NFC Tag';

  @override
  String get readyToScanNfcTag => 'Ready to Scan';

  @override
  String get scanNfcTagActionLabel => 'Scan your NFC tag.';

  @override
  String get settingsNfcChipConfiguring => 'NFC Chip Configuring';

  @override
  String get settingsQrCodeConfiguring => 'QR Code Configuring';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get settingsVersionFallback => 'Pauza';

  @override
  String settingsVersionLabel(String version) {
    return 'Pauza v$version';
  }

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
  String weekDaysShort(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String weekDays(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'mon': 'Monday',
      'tue': 'Tuesday',
      'wed': 'Wednesday',
      'thu': 'Thursday',
      'fri': 'Friday',
      'sat': 'Saturday',
      'sun': 'Sunday',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

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
  String get permissionUsageAccessBody =>
      'Pauza uses Usage Access to understand which apps are active and enforce your blocking rules. This data stays on your device.';

  @override
  String get permissionAccessibilityTitle => 'Enable Accessibility Service';

  @override
  String get permissionAccessibilityBody =>
      'Pauza uses Accessibility to detect when a blocked app opens so it can show the block screen immediately.';

  @override
  String get permissionExactAlarmTitle => 'Allow Exact Alarms';

  @override
  String get permissionExactAlarmBody =>
      'Exact alarms keep schedules and pause timers accurate so blocks start and end on time.';

  @override
  String get permissionFamilyControlsTitle => 'Allow Family Controls (Screen Time)';

  @override
  String get permissionFamilyControlsBody =>
      'Pauza uses Family Controls / Screen Time authorization to manage app restrictions on iOS.';

  @override
  String get permissionsRequiredTitle => 'Permissions Required';

  @override
  String get permissionsRequiredBody =>
      'To help you stay focused and block distracting apps effectively, Pauza needs the permissions listed below. Your data stays private on your device.';

  @override
  String get permissionUsageAccessShortBody => 'Monitor usage and enforce limits';

  @override
  String get permissionAccessibilityShortBody => 'Identify and block restricted apps';

  @override
  String get permissionExactAlarmShortBody => 'Keep schedules and timers accurate';

  @override
  String get permissionFamilyControlsShortBody => 'Manage app restrictions on iOS';

  @override
  String permissionCurrentStatusLabel(String status) {
    return 'Current status: $status';
  }

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
  String get nfcOpenSettingsButton => 'Open settings';

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
  String get nfcChipHoldCardNearDevice => 'Hold your device near the NFC tag to scan';

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
  String nfcChipConfigLinkedOnDate(String date) {
    return 'Linked on $date';
  }

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
  String blockedAppsCountLabel(int count) {
    return 'Blocked apps: $count';
  }

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
  String modeBlockedAppsSelectedCountLabel(int count) {
    return 'Selected apps: $count';
  }

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
  String modeAllowedPausesOutOfRangeError(int min, int max) {
    return 'Allowed pauses must be between $min and $max';
  }

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
  String appsSelectedCountLabel(int count) {
    return '$count selected';
  }

  @override
  String get allAppsCategory => 'All Apps';

  @override
  String get selectAllButton => 'Select all';

  @override
  String get deselectAllButton => 'Deselect all';

  @override
  String get otherAppsCategory => 'Other';

  @override
  String homeGreeting(String hour) {
    String _temp0 = intl.Intl.selectLogic(hour, {
      '0': 'Good Night',
      '1': 'Good Night',
      '2': 'Good Night',
      '3': 'Good Night',
      '4': 'Good Night',
      '5': 'Good Morning',
      '6': 'Good Morning',
      '7': 'Good Morning',
      '8': 'Good Morning',
      '9': 'Good Morning',
      '10': 'Good Morning',
      '11': 'Good Morning',
      '12': 'Good Afternoon',
      '13': 'Good Afternoon',
      '14': 'Good Afternoon',
      '15': 'Good Afternoon',
      '16': 'Good Afternoon',
      '17': 'Good Evening',
      '18': 'Good Evening',
      '19': 'Good Evening',
      '20': 'Good Evening',
      '21': 'Good Evening',
      '22': 'Good Night',
      '23': 'Good Night',
      'other': 'Good Night',
    });
    return '$_temp0';
  }

  @override
  String get homeDashboardTitle => 'Pauza Dashboard';

  @override
  String get homePauzaSessionLabel => 'Pauza Session';

  @override
  String get homeSessionDurationLabel => 'Session Duration';

  @override
  String get homeQuickPauseLabel => 'Quick Pause';

  @override
  String get pausedTitle => 'Paused';

  @override
  String get reminaingLabel => 'Remaining';

  @override
  String get pausedTakeABreathLabel => 'Take a breath';

  @override
  String pauseDurationMinutes(num minutes) {
    return '${minutes}m';
  }

  @override
  String get homeResumeButtonLabel => 'Resume';

  @override
  String get homeCurrentModeLabel => 'Current mode';

  @override
  String homeDayStreakLabel(int count) {
    return '$count Day Streak';
  }

  @override
  String homeDurationHoursMinutesLabel(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

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
  String statsDeltaVsLastPeriod(String value) {
    return '$value vs last period';
  }

  @override
  String get statsPermissionRequiredTitle => 'Usage permission required';

  @override
  String get statsPermissionRequiredBody => 'Allow Usage Access to view Android usage statistics.';

  @override
  String get statsLoadFailed => 'Failed to load usage statistics.';

  @override
  String get statsNoUsageData => 'No usage data for the selected period.';

  @override
  String get statsIosReportUnavailableTitle => 'iOS report unavailable';

  @override
  String get statsIosReportUnavailableBody =>
      'Make sure Screen Time permission and Device Activity Report extension are configured.';

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
  String get authOtpDidNotReceiveCode => 'Didn\'t receive a code?';

  @override
  String get authOtpResendCode => 'Resend Code';

  @override
  String authOtpAvailableInLabel(String minutes, String seconds) {
    return 'Available in $minutes:$seconds';
  }

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
  String get authFailureStorage => 'Could not access secure storage. Please try again.';

  @override
  String get authFailureUnknown => 'Could not sign in. Please try again.';
}
