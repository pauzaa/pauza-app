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
}
