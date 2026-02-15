import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.g.dart';
import 'app_localizations_ru.g.dart';
import 'app_localizations_uz.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
  ];

  /// The name of the application.
  ///
  /// In en, this message translates to:
  /// **'Pauza'**
  String get appName;

  /// Title for the home screen.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Title for the stats screen and navigation destination.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// Title for the leaderboard screen and navigation destination.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// Title for the profile screen and navigation destination.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Title shown when a page is not found.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// Label for a confirm action on dialogs or forms.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// Label for canceling an action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Label to acknowledge information.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// Affirmative action label.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesButton;

  /// No description provided for @weekDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{key, select, mon {Mon} tue {Tue} wed {Wed} thu {Thu} fri {Fri} sat {Sat} sun {Sun} other {Unknown}}'**
  String weekDaysShort(String key);

  /// No description provided for @weekDays.
  ///
  /// In en, this message translates to:
  /// **'{key, select, mon {Monday} tue {Tuesday} wed {Wednesday} thu {Thursday} fri {Friday} sat {Saturday} sun {Sunday} other {Unknown}}'**
  String weekDays(String key);

  /// Negative or dismissive action label.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noButton;

  /// Label for reattempting a failed action.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Label for closing a sheet, dialog, or screen.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// Label to move forward in a flow.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// Label to move back in a flow.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousButton;

  /// Label to submit a form or send data.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// Label to navigate back globally.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// Text displayed while content is loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingLabel;

  /// Title shown when an error occurs.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// Title shown when an action completes successfully.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// Placeholder text for search inputs.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchPlaceholder;

  /// Message displayed when a list has no content.
  ///
  /// In en, this message translates to:
  /// **'No items to show'**
  String get emptyStateMessage;

  /// Label to start an action or mode.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// Label to stop an active action or mode.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopButton;

  /// Title for selecting a mode.
  ///
  /// In en, this message translates to:
  /// **'Select mode'**
  String get selectModeTitle;

  /// Button label to add a new mode.
  ///
  /// In en, this message translates to:
  /// **'Add new mode'**
  String get addModeButton;

  /// Button label to edit a mode.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editModeButton;

  /// Button label to delete a mode.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteModeButton;

  /// Title for the delete mode confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete mode?'**
  String get deleteModeTitle;

  /// Warning message shown when deleting a mode.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteModeMessage;

  /// Message displayed for features not yet available.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonMessage;

  /// Message shown when no modes have been created.
  ///
  /// In en, this message translates to:
  /// **'No modes yet'**
  String get noModesEmptyState;

  /// Toast or hint prompting user to choose a mode before starting.
  ///
  /// In en, this message translates to:
  /// **'Select mode'**
  String get selectMode;

  /// Toast shown when user tries to start a session while blocking is already active.
  ///
  /// In en, this message translates to:
  /// **'Already blocking'**
  String get alreadyBlocking;

  /// Title for the Usage Access permission request.
  ///
  /// In en, this message translates to:
  /// **'Allow Usage Access'**
  String get permissionUsageAccessTitle;

  /// Explanation of why Usage Access permission is needed.
  ///
  /// In en, this message translates to:
  /// **'Pauza uses Usage Access to understand which apps are active and enforce your blocking rules. This data stays on your device.'**
  String get permissionUsageAccessBody;

  /// Title for the Accessibility Service permission request.
  ///
  /// In en, this message translates to:
  /// **'Enable Accessibility Service'**
  String get permissionAccessibilityTitle;

  /// Explanation of why Accessibility permission is needed.
  ///
  /// In en, this message translates to:
  /// **'Pauza uses Accessibility to detect when a blocked app opens so it can show the block screen immediately.'**
  String get permissionAccessibilityBody;

  /// Title for the Exact Alarms permission request.
  ///
  /// In en, this message translates to:
  /// **'Allow Exact Alarms'**
  String get permissionExactAlarmTitle;

  /// Explanation of why Exact Alarms permission is needed.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms keep schedules and pause timers accurate so blocks start and end on time.'**
  String get permissionExactAlarmBody;

  /// Title for the Family Controls permission request.
  ///
  /// In en, this message translates to:
  /// **'Allow Family Controls (Screen Time)'**
  String get permissionFamilyControlsTitle;

  /// Explanation of why Family Controls permission is needed.
  ///
  /// In en, this message translates to:
  /// **'Pauza uses Family Controls / Screen Time authorization to manage app restrictions on iOS.'**
  String get permissionFamilyControlsBody;

  /// Title for the combined permissions gate screen.
  ///
  /// In en, this message translates to:
  /// **'Permissions Required'**
  String get permissionsRequiredTitle;

  /// Description for the combined permissions gate screen.
  ///
  /// In en, this message translates to:
  /// **'To help you stay focused and block distracting apps effectively, Pauza needs the permissions listed below. Your data stays private on your device.'**
  String get permissionsRequiredBody;

  /// Short description for Usage Access permission row.
  ///
  /// In en, this message translates to:
  /// **'Monitor usage and enforce limits'**
  String get permissionUsageAccessShortBody;

  /// Short description for Accessibility permission row.
  ///
  /// In en, this message translates to:
  /// **'Identify and block restricted apps'**
  String get permissionAccessibilityShortBody;

  /// Short description for Exact Alarms permission row.
  ///
  /// In en, this message translates to:
  /// **'Keep schedules and timers accurate'**
  String get permissionExactAlarmShortBody;

  /// Short description for Family Controls permission row.
  ///
  /// In en, this message translates to:
  /// **'Manage app restrictions on iOS'**
  String get permissionFamilyControlsShortBody;

  /// No description provided for @permissionCurrentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Current status: {status}'**
  String permissionCurrentStatusLabel(String status);

  /// Label shown when a permission has been granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permissionStatusGranted;

  /// Label shown when a permission has been denied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get permissionStatusDenied;

  /// Label shown when a permission is restricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get permissionStatusRestricted;

  /// Label shown when a permission status is not yet determined.
  ///
  /// In en, this message translates to:
  /// **'Not determined'**
  String get permissionStatusNotDetermined;

  /// Button label to open system settings for permissions.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permissionOpenSettingsButton;

  /// Button label to grant permission access.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get permissionAllowAccessButton;

  /// No description provided for @blockedAppsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Blocked apps: {count}'**
  String blockedAppsCountLabel(int count);

  /// Title for the create mode screen.
  ///
  /// In en, this message translates to:
  /// **'Create mode'**
  String get createModeTitle;

  /// Title for the edit mode screen.
  ///
  /// In en, this message translates to:
  /// **'Edit mode'**
  String get editModeTitle;

  /// Label for the mode title input field.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get modeTitleFieldLabel;

  /// Label for the text displayed on the block screen.
  ///
  /// In en, this message translates to:
  /// **'Text on shield screen'**
  String get modeTextOnScreenFieldLabel;

  /// Label for the mode description input field.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get modeDescriptionFieldLabel;

  /// Label for the mode enabled toggle.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get modeEnabledLabel;

  /// Title for the blocked apps section in mode settings.
  ///
  /// In en, this message translates to:
  /// **'Blocked apps'**
  String get modeBlockedAppsSectionTitle;

  /// Button label to choose apps to block.
  ///
  /// In en, this message translates to:
  /// **'Choose apps'**
  String get modeBlockedAppsChooseButton;

  /// Label for the app search input.
  ///
  /// In en, this message translates to:
  /// **'Search apps'**
  String get modeBlockedAppsSearchLabel;

  /// Error message shown when no apps are selected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one app'**
  String get modeBlockedAppsRequiredError;

  /// No description provided for @modeBlockedAppsSelectedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected apps: {count}'**
  String modeBlockedAppsSelectedCountLabel(int count);

  /// Error message shown when a required field is empty.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get modeRequiredFieldError;

  /// Error message shown when mode data fails to load.
  ///
  /// In en, this message translates to:
  /// **'Unable to load mode data'**
  String get modeLoadFailedMessage;

  /// Error message shown when saving a mode fails.
  ///
  /// In en, this message translates to:
  /// **'Unable to save mode'**
  String get modeSaveFailedMessage;

  /// Error message shown when app list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Unable to load apps'**
  String get modeAppsLoadFailedMessage;

  /// Button label to save changes.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Title for the app selection sheet.
  ///
  /// In en, this message translates to:
  /// **'Select apps'**
  String get selectAppsTitle;

  /// Label for the done button.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// Category label for apps with unknown category.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherAppsCategory;

  /// Time-of-day greeting. Hour of day (0-23) in local time.
  ///
  /// In en, this message translates to:
  /// **'{hour, select, 0{Good Night} 1{Good Night} 2{Good Night} 3{Good Night} 4{Good Night} 5{Good Morning} 6{Good Morning} 7{Good Morning} 8{Good Morning} 9{Good Morning} 10{Good Morning} 11{Good Morning} 12{Good Afternoon} 13{Good Afternoon} 14{Good Afternoon} 15{Good Afternoon} 16{Good Afternoon} 17{Good Evening} 18{Good Evening} 19{Good Evening} 20{Good Evening} 21{Good Evening} 22{Good Night} 23{Good Night} other{Good Night}}'**
  String homeGreeting(String hour);

  /// No description provided for @homeDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Pauza Dashboard'**
  String get homeDashboardTitle;

  /// No description provided for @homePauzaSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Pauza Session'**
  String get homePauzaSessionLabel;

  /// No description provided for @homeSessionDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Session Duration'**
  String get homeSessionDurationLabel;

  /// No description provided for @homeQuickPauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick Pause'**
  String get homeQuickPauseLabel;

  /// No description provided for @homeCurrentModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Current mode'**
  String get homeCurrentModeLabel;

  /// No description provided for @homeDayStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String homeDayStreakLabel(int count);

  /// No description provided for @homeDurationHoursMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String homeDurationHoursMinutesLabel(int hours, int minutes);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'uz':
      {
        switch (locale.scriptCode) {
          case 'Cyrl':
            return AppLocalizationsUzCyrl();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
