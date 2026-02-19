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

  /// Fallback display name for profile screen when current user data is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get profileDisplayNameFallback;

  /// Fallback username for profile screen when current user data is unavailable.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get profileUsernameFallback;

  /// Navigation item title for editing profile details.
  ///
  /// In en, this message translates to:
  /// **'Edit Info'**
  String get profileEditInfoNavTitle;

  /// Title for the edit profile screen.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditTitle;

  /// Action label for changing profile photo.
  ///
  /// In en, this message translates to:
  /// **'CHANGE PHOTO'**
  String get profileEditChangePhoto;

  /// Action label shown while a profile photo is uploading.
  ///
  /// In en, this message translates to:
  /// **'UPLOADING...'**
  String get profileEditUploadingPhoto;

  /// Label for the name field on edit profile screen.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileEditNameLabel;

  /// Hint for the name field on edit profile screen.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileEditNameHint;

  /// Label for the username field on edit profile screen.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profileEditUsernameLabel;

  /// Hint for the username field on edit profile screen.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get profileEditUsernameHint;

  /// Primary save button label on the edit profile screen.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileEditSaveButton;

  /// Title for the profile photo action bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profileEditChangePhotoSheetTitle;

  /// Bottom sheet option title for taking a photo.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get profileEditTakePhotoTitle;

  /// Bottom sheet option subtitle for taking a photo.
  ///
  /// In en, this message translates to:
  /// **'Use your camera to snap a new one'**
  String get profileEditTakePhotoSubtitle;

  /// Bottom sheet option title for selecting from gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get profileEditChooseFromGalleryTitle;

  /// Bottom sheet option subtitle for selecting from gallery.
  ///
  /// In en, this message translates to:
  /// **'Pick a photo from your phone\'s library'**
  String get profileEditChooseFromGallerySubtitle;

  /// Validation message for invalid profile username.
  ///
  /// In en, this message translates to:
  /// **'Use 3-30 lowercase letters, digits, or underscore'**
  String get profileEditInvalidUsernameError;

  /// Validation message when chosen username is not available.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get profileEditUsernameTakenError;

  /// General validation error for edit profile flow.
  ///
  /// In en, this message translates to:
  /// **'Please check your profile details'**
  String get profileEditValidationError;

  /// Network failure message shown on edit profile flow.
  ///
  /// In en, this message translates to:
  /// **'Unable to update profile. Check your connection'**
  String get profileEditNetworkError;

  /// Navigation item title for profile settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsNavTitle;

  /// Title shown in the settings screen app bar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Section title for general settings.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneralSectionTitle;

  /// Label for settings notifications row.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Label for settings language row.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Title for language selection dialog in settings.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get settingsLanguagePickerTitle;

  /// Section title for session ending confirmation settings.
  ///
  /// In en, this message translates to:
  /// **'Session Ending'**
  String get settingsSessionEndingConfSectionTitle;

  /// Title for the NFC tag scanning screen.
  ///
  /// In en, this message translates to:
  /// **'Scan NFC Tag'**
  String get scanNfcChipTitle;

  /// Title shown when the user is ready to scan an NFC tag.
  ///
  /// In en, this message translates to:
  /// **'Ready to Scan'**
  String get readyToScanNfcTag;

  /// Action label to scan an NFC tag.
  ///
  /// In en, this message translates to:
  /// **'Scan your NFC tag.'**
  String get scanNfcTagActionLabel;

  /// Label for NFC chip configuring settings row.
  ///
  /// In en, this message translates to:
  /// **'NFC Chip Configuring'**
  String get settingsNfcChipConfiguring;

  /// Label for QR code configuring settings row.
  ///
  /// In en, this message translates to:
  /// **'QR Code Configuring'**
  String get settingsQrCodeConfiguring;

  /// Label for sign out button in settings.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// Fallback label in settings footer when app version is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Pauza'**
  String get settingsVersionFallback;

  /// Formatted app version label shown in settings footer.
  ///
  /// In en, this message translates to:
  /// **'Pauza v{version}'**
  String settingsVersionLabel(String version);

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

  /// Button label to open NFC-related system settings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get nfcOpenSettingsButton;

  /// Title shown when NFC is available.
  ///
  /// In en, this message translates to:
  /// **'NFC is ready'**
  String get nfcGuidanceAvailableTitle;

  /// Body shown when NFC is available.
  ///
  /// In en, this message translates to:
  /// **'Your device is ready to scan NFC tags.'**
  String get nfcGuidanceAvailableBody;

  /// Title shown when NFC is supported but disabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on NFC'**
  String get nfcGuidanceDisabledTitle;

  /// Body shown when NFC is supported but disabled.
  ///
  /// In en, this message translates to:
  /// **'NFC is turned off on this device. Enable it in system settings to continue.'**
  String get nfcGuidanceDisabledBody;

  /// Title shown when NFC is not supported on the current device.
  ///
  /// In en, this message translates to:
  /// **'NFC is not supported'**
  String get nfcGuidanceNotSupportedTitle;

  /// Body shown when NFC is not supported on the current device.
  ///
  /// In en, this message translates to:
  /// **'This device does not support NFC scanning.'**
  String get nfcGuidanceNotSupportedBody;

  /// Title shown when NFC status cannot be determined.
  ///
  /// In en, this message translates to:
  /// **'NFC status unavailable'**
  String get nfcGuidanceUnknownTitle;

  /// Body shown when NFC status cannot be determined.
  ///
  /// In en, this message translates to:
  /// **'We could not determine NFC availability right now. Try again in a moment.'**
  String get nfcGuidanceUnknownBody;

  /// Title shown on NFC tag linking screen.
  ///
  /// In en, this message translates to:
  /// **'Configure NFC Tag'**
  String get nfcChipConfigTitle;

  /// Body text shown on NFC tag linking screen.
  ///
  /// In en, this message translates to:
  /// **'Scan an NFC tag to link it with Pauza. You will need this tag to end your focus sessions.'**
  String get nfcChipConfigBody;

  /// Primary action to start linking an NFC tag.
  ///
  /// In en, this message translates to:
  /// **'Link NFC Tag'**
  String get nfcChipConfigLinkButton;

  /// Primary action label while NFC scan is in progress.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get nfcChipConfigScanningButton;

  /// Toast shown when NFC tag has been linked.
  ///
  /// In en, this message translates to:
  /// **'NFC tag linked successfully.'**
  String get nfcChipConfigLinkedSuccess;

  /// Toast shown when NFC tag already exists in linked tags table.
  ///
  /// In en, this message translates to:
  /// **'This NFC tag is already linked.'**
  String get nfcChipConfigAlreadyLinked;

  /// Instruction shown when the user should hold the NFC tag near the device to scan.
  ///
  /// In en, this message translates to:
  /// **'Hold your device near the NFC tag to scan'**
  String get nfcChipHoldCardNearDevice;

  /// Error shown when scanned NFC tag has no stable UID.
  ///
  /// In en, this message translates to:
  /// **'This NFC tag cannot be linked because it does not provide an identifier.'**
  String get nfcChipConfigUidMissingError;

  /// Error shown when NFC scan or linking fails.
  ///
  /// In en, this message translates to:
  /// **'Unable to link NFC tag. Please try again.'**
  String get nfcChipConfigScanFailed;

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

  /// Section title for mode icon selection.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get modeIconSectionTitle;

  /// Button label to choose mode icon.
  ///
  /// In en, this message translates to:
  /// **'Choose icon'**
  String get modeIconChooseButton;

  /// Title for the mode icon picker sheet.
  ///
  /// In en, this message translates to:
  /// **'Pick an icon'**
  String get modeIconPickerTitle;

  /// Subtitle shown in mode icon picker.
  ///
  /// In en, this message translates to:
  /// **'Choose one icon for this mode'**
  String get modeIconPickerSubtitle;

  /// Label for tune mode icon.
  ///
  /// In en, this message translates to:
  /// **'Tune'**
  String get modeIconLabelTune;

  /// Label for psychology mode icon.
  ///
  /// In en, this message translates to:
  /// **'Mind'**
  String get modeIconLabelPsychology;

  /// Label for timer mode icon.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get modeIconLabelTimer;

  /// Label for bolt mode icon.
  ///
  /// In en, this message translates to:
  /// **'Bolt'**
  String get modeIconLabelBolt;

  /// Label for rocket launch mode icon.
  ///
  /// In en, this message translates to:
  /// **'Rocket'**
  String get modeIconLabelRocketLaunch;

  /// Label for self improvement mode icon.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get modeIconLabelSelfImprovement;

  /// Label for fitness center mode icon.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get modeIconLabelFitnessCenter;

  /// Label for school mode icon.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get modeIconLabelSchool;

  /// Label for work mode icon.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get modeIconLabelWork;

  /// Label for menu book mode icon.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get modeIconLabelMenuBook;

  /// Label for music note mode icon.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get modeIconLabelMusicNote;

  /// Label for nightlight mode icon.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get modeIconLabelNightlight;

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

  /// Subtitle for blocked apps selector card.
  ///
  /// In en, this message translates to:
  /// **'Customize what to block'**
  String get modeBlockedAppsSubtitle;

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

  /// Title for schedule section on mode editor.
  ///
  /// In en, this message translates to:
  /// **'Schedule (Optional)'**
  String get modeScheduleTitle;

  /// Label for schedule start time picker.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get modeScheduleStartTimeLabel;

  /// Label for schedule end time picker.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get modeScheduleEndTimeLabel;

  /// Error shown when schedule is enabled without selected days.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day'**
  String get modeScheduleDaysRequiredError;

  /// Section title for strictness controls.
  ///
  /// In en, this message translates to:
  /// **'Strictness'**
  String get modeStrictnessTitle;

  /// Title for allowed pauses control.
  ///
  /// In en, this message translates to:
  /// **'Allowed pauses'**
  String get modeAllowedPausesTitle;

  /// Subtitle for allowed pauses control.
  ///
  /// In en, this message translates to:
  /// **'Short breaks during session'**
  String get modeAllowedPausesSubtitle;

  /// Error shown when allowed pauses count is out of range.
  ///
  /// In en, this message translates to:
  /// **'Allowed pauses must be between {min} and {max}'**
  String modeAllowedPausesOutOfRangeError(int min, int max);

  /// Button label for deleting the edited mode.
  ///
  /// In en, this message translates to:
  /// **'Delete Focus Mode'**
  String get modeDeleteFocusButton;

  /// Bottom call to action to save mode changes.
  ///
  /// In en, this message translates to:
  /// **'Save Mode'**
  String get modeSaveButton;

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

  /// Error message shown when deleting a mode fails.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete mode'**
  String get modeDeleteFailedMessage;

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

  /// Title for the redesigned Android app selection sheet.
  ///
  /// In en, this message translates to:
  /// **'Select Apps for Pauza'**
  String get selectAppsForPauzaTitle;

  /// Label for the done button.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// Label for selecting apps and closing the bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectButton;

  /// Badge label showing how many apps are selected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String appsSelectedCountLabel(int count);

  /// Filter chip label that shows all app categories.
  ///
  /// In en, this message translates to:
  /// **'All Apps'**
  String get allAppsCategory;

  /// Action to select every app in a category.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAllButton;

  /// Action to deselect every app in a category.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get deselectAllButton;

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

  /// Title for the home dashboard screen.
  ///
  /// In en, this message translates to:
  /// **'Pauza Dashboard'**
  String get homeDashboardTitle;

  /// Label indicating an active Pauza session.
  ///
  /// In en, this message translates to:
  /// **'Pauza Session'**
  String get homePauzaSessionLabel;

  /// Label for the session duration display.
  ///
  /// In en, this message translates to:
  /// **'Session Duration'**
  String get homeSessionDurationLabel;

  /// Label for the quick pause feature.
  ///
  /// In en, this message translates to:
  /// **'Quick Pause'**
  String get homeQuickPauseLabel;

  /// Title for the paused session.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedTitle;

  /// Label for the remaining time.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get reminaingLabel;

  /// Label for the take a breath button.
  ///
  /// In en, this message translates to:
  /// **'Take a breath'**
  String get pausedTakeABreathLabel;

  /// Quick pause duration in minutes with 'm' suffix
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String pauseDurationMinutes(num minutes);

  /// Label for the resume button.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get homeResumeButtonLabel;

  /// Label indicating the currently active mode.
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

  /// Title for device usage statistics section.
  ///
  /// In en, this message translates to:
  /// **'Device Usage'**
  String get deviceUsage;

  /// Tab label for usage statistics.
  ///
  /// In en, this message translates to:
  /// **'Usage Stats'**
  String get usageStatsTab;

  /// Tab label for blocking statistics.
  ///
  /// In en, this message translates to:
  /// **'Blocking Stats'**
  String get blockingStatsTab;

  /// Label for current week time period.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Label for total time display.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// Label for usage trend indicator.
  ///
  /// In en, this message translates to:
  /// **'Usage Trend'**
  String get usageTrend;

  /// Label for daily average usage statistic.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get statsDailyAverage;

  /// Category label for social media apps.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get statsBucketSocial;

  /// Category label for productivity apps.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get statsBucketProductivity;

  /// Category label for other uncategorized apps.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get statsBucketOther;

  /// Title for app usage statistics section.
  ///
  /// In en, this message translates to:
  /// **'App Usage'**
  String get statsAppUsage;

  /// Column header for app name in usage table.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get statsUsageTableAppColumn;

  /// Column header for usage time in usage table.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get statsUsageTableUsageColumn;

  /// Column header for app launch count in usage table.
  ///
  /// In en, this message translates to:
  /// **'Launches'**
  String get statsUsageTableLaunchesColumn;

  /// Column header for last used time in usage table.
  ///
  /// In en, this message translates to:
  /// **'Last used'**
  String get statsUsageTableLastUsedColumn;

  /// No description provided for @statsDeltaVsLastPeriod.
  ///
  /// In en, this message translates to:
  /// **'{value} vs last period'**
  String statsDeltaVsLastPeriod(String value);

  /// Title for usage permission required dialog.
  ///
  /// In en, this message translates to:
  /// **'Usage permission required'**
  String get statsPermissionRequiredTitle;

  /// Body text for usage permission required dialog.
  ///
  /// In en, this message translates to:
  /// **'Allow Usage Access to view Android usage statistics.'**
  String get statsPermissionRequiredBody;

  /// Error message when stats fail to load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load usage statistics.'**
  String get statsLoadFailed;

  /// Message shown when no usage data is available.
  ///
  /// In en, this message translates to:
  /// **'No usage data for the selected period.'**
  String get statsNoUsageData;

  /// Title for iOS report unavailable message.
  ///
  /// In en, this message translates to:
  /// **'iOS report unavailable'**
  String get statsIosReportUnavailableTitle;

  /// Body text for iOS report unavailable message.
  ///
  /// In en, this message translates to:
  /// **'Make sure Screen Time permission and Device Activity Report extension are configured.'**
  String get statsIosReportUnavailableBody;

  /// Tagline displayed on authentication screens.
  ///
  /// In en, this message translates to:
  /// **'Focus & Wellbeing'**
  String get authTagline;

  /// Label for email address input field.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmailAddress;

  /// Hint text for email input field.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get authEmailHint;

  /// Label for password input field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Link text for password recovery.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Button label for login action.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogIn;

  /// Title for OTP verification screen.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get authOtpTitle;

  /// First part of OTP screen subtitle before email address.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to your email address '**
  String get authOtpSubtitlePrefix;

  /// Second part of OTP screen subtitle after email address.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get authOtpSubtitleSuffix;

  /// Button label for OTP verification.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authOtpVerifyButton;

  /// Prompt asking if user didn't receive OTP code.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive a code?'**
  String get authOtpDidNotReceiveCode;

  /// Button label to resend OTP code.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get authOtpResendCode;

  /// No description provided for @authOtpAvailableInLabel.
  ///
  /// In en, this message translates to:
  /// **'Available in {minutes}:{seconds}'**
  String authOtpAvailableInLabel(String minutes, String seconds);

  /// Validation error when required field is empty.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get authValidationRequired;

  /// Validation error for invalid email format.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authValidationInvalidEmail;

  /// Error message for invalid login credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authFailureInvalidCredentials;

  /// Error message for invalid OTP code.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code.'**
  String get authFailureInvalidOtp;

  /// Error when OTP challenge is missing or expired.
  ///
  /// In en, this message translates to:
  /// **'Verification challenge expired. Try again.'**
  String get authFailureOtpChallengeMissing;

  /// Error when secure storage is inaccessible.
  ///
  /// In en, this message translates to:
  /// **'Could not access secure storage. Please try again.'**
  String get authFailureStorage;

  /// Generic authentication failure message.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Please try again.'**
  String get authFailureUnknown;
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
