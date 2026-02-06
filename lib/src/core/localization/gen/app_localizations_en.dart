// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

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
  String blockedAppsCountLabel(int count) {
    return 'Blocked apps: $count';
  }
}
