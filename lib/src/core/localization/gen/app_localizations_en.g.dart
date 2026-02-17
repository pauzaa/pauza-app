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
  String get permissionFamilyControlsTitle =>
      'Allow Family Controls (Screen Time)';

  @override
  String get permissionFamilyControlsBody =>
      'Pauza uses Family Controls / Screen Time authorization to manage app restrictions on iOS.';

  @override
  String get permissionsRequiredTitle => 'Permissions Required';

  @override
  String get permissionsRequiredBody =>
      'To help you stay focused and block distracting apps effectively, Pauza needs the permissions listed below. Your data stays private on your device.';

  @override
  String get permissionUsageAccessShortBody =>
      'Monitor usage and enforce limits';

  @override
  String get permissionAccessibilityShortBody =>
      'Identify and block restricted apps';

  @override
  String get permissionExactAlarmShortBody =>
      'Keep schedules and timers accurate';

  @override
  String get permissionFamilyControlsShortBody =>
      'Manage app restrictions on iOS';

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
  String get nfcGuidanceAvailableBody =>
      'Your device is ready to scan NFC tags.';

  @override
  String get nfcGuidanceDisabledTitle => 'Turn on NFC';

  @override
  String get nfcGuidanceDisabledBody =>
      'NFC is turned off on this device. Enable it in system settings to continue.';

  @override
  String get nfcGuidanceNotSupportedTitle => 'NFC is not supported';

  @override
  String get nfcGuidanceNotSupportedBody =>
      'This device does not support NFC scanning.';

  @override
  String get nfcGuidanceUnknownTitle => 'NFC status unavailable';

  @override
  String get nfcGuidanceUnknownBody =>
      'We could not determine NFC availability right now. Try again in a moment.';

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
  String get statsPermissionRequiredBody =>
      'Allow Usage Access to view Android usage statistics.';

  @override
  String get statsLoadFailed => 'Failed to load usage statistics.';

  @override
  String get statsNoUsageData => 'No usage data for the selected period.';

  @override
  String get statsIosReportUnavailableTitle => 'iOS report unavailable';

  @override
  String get statsIosReportUnavailableBody =>
      'Make sure Screen Time permission and Device Activity Report extension are configured.';
}
