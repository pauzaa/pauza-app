import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pauza'**
  String get appName;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @notFoundTitle.
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

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @stopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopButton;

  /// No description provided for @selectModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select mode'**
  String get selectModeTitle;

  /// No description provided for @addModeButton.
  ///
  /// In en, this message translates to:
  /// **'Add new mode'**
  String get addModeButton;

  /// No description provided for @editModeButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editModeButton;

  /// No description provided for @deleteModeButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteModeButton;

  /// No description provided for @deleteModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete mode?'**
  String get deleteModeTitle;

  /// No description provided for @deleteModeMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteModeMessage;

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonMessage;

  /// No description provided for @noModesEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No modes yet'**
  String get noModesEmptyState;

  /// No description provided for @permissionUsageAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Usage Access'**
  String get permissionUsageAccessTitle;

  /// No description provided for @permissionUsageAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Pauza needs Usage Access to read app activity and apply blocking rules.'**
  String get permissionUsageAccessBody;

  /// No description provided for @permissionAccessibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Accessibility Service'**
  String get permissionAccessibilityTitle;

  /// No description provided for @permissionAccessibilityBody.
  ///
  /// In en, this message translates to:
  /// **'Pauza needs Accessibility Service to detect when blocked apps are opened.'**
  String get permissionAccessibilityBody;

  /// No description provided for @permissionFamilyControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Family Controls'**
  String get permissionFamilyControlsTitle;

  /// No description provided for @permissionFamilyControlsBody.
  ///
  /// In en, this message translates to:
  /// **'Pauza needs Family Controls authorization to manage app restrictions on iOS.'**
  String get permissionFamilyControlsBody;

  /// No description provided for @permissionCurrentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Current status: {status}'**
  String permissionCurrentStatusLabel(String status);

  /// No description provided for @permissionStatusGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permissionStatusGranted;

  /// No description provided for @permissionStatusDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get permissionStatusDenied;

  /// No description provided for @permissionStatusRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get permissionStatusRestricted;

  /// No description provided for @permissionStatusNotDetermined.
  ///
  /// In en, this message translates to:
  /// **'Not determined'**
  String get permissionStatusNotDetermined;

  /// No description provided for @permissionOpenSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permissionOpenSettingsButton;

  /// No description provided for @permissionAllowAccessButton.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get permissionAllowAccessButton;

  /// No description provided for @blockedAppsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Blocked apps: {count}'**
  String blockedAppsCountLabel(int count);
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
