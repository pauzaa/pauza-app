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
  String get modeEnabledLabel => 'Enabled';

  @override
  String get modeBlockedAppsSectionTitle => 'Blocked apps';

  @override
  String get modeBlockedAppsChooseButton => 'Choose apps';

  @override
  String get modeBlockedAppsSearchLabel => 'Search apps';

  @override
  String get modeBlockedAppsRequiredError => 'Select at least one app';

  @override
  String modeBlockedAppsSelectedCountLabel(int count) {
    return 'Selected apps: $count';
  }

  @override
  String get modeRequiredFieldError => 'This field is required';

  @override
  String get modeLoadFailedMessage => 'Unable to load mode data';

  @override
  String get modeSaveFailedMessage => 'Unable to save mode';

  @override
  String get modeAppsLoadFailedMessage => 'Unable to load apps';

  @override
  String get saveButton => 'Save';

  @override
  String get selectAppsTitle => 'Select apps';

  @override
  String get doneButton => 'Done';

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
}
