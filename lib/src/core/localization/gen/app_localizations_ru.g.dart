// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Pauza';

  @override
  String get homeTitle => 'Главная';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get leaderboardTitle => 'Лидерборд';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileDisplayNameFallback => 'Неизвестный пользователь';

  @override
  String get profileUsernameFallback => 'username';

  @override
  String get profileEditInfoNavTitle => 'Изменить профиль';

  @override
  String get profileEditTitle => 'Редактировать профиль';

  @override
  String get profileEditChangePhoto => 'ИЗМЕНИТЬ ФОТО';

  @override
  String get profileEditUploadingPhoto => 'ЗАГРУЗКА...';

  @override
  String get profileEditNameLabel => 'Имя';

  @override
  String get profileEditNameHint => 'Ваше имя';

  @override
  String get profileEditUsernameLabel => 'Имя пользователя';

  @override
  String get profileEditUsernameHint => 'username';

  @override
  String get profileEditSaveButton => 'Сохранить изменения';

  @override
  String get profileEditChangePhotoSheetTitle => 'Изменить фото профиля';

  @override
  String get profileEditTakePhotoTitle => 'Сделать фото';

  @override
  String get profileEditTakePhotoSubtitle => 'Сделайте новый снимок на камеру';

  @override
  String get profileEditChooseFromGalleryTitle => 'Выбрать из галереи';

  @override
  String get profileEditChooseFromGallerySubtitle =>
      'Выберите фото из галереи телефона';

  @override
  String get profileEditInvalidUsernameError =>
      'Используйте 3-30 строчных символов, цифр или _';

  @override
  String get profileEditUsernameTakenError => 'Это имя пользователя уже занято';

  @override
  String get profileEditValidationError => 'Проверьте данные профиля';

  @override
  String get profileEditNetworkError =>
      'Не удалось обновить профиль. Проверьте соединение';

  @override
  String get profileSettingsNavTitle => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsGeneralSectionTitle => 'Общие';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguagePickerTitle => 'Выберите язык';

  @override
  String get settingsSessionEndingConfSectionTitle => 'Session Ending';

  @override
  String get scanNfcChipTitle => 'Scan NFC Tag';

  @override
  String get readyToScanNfcTag => 'Ready to Scan';

  @override
  String get scanNfcTagActionLabel => 'Scan your NFC tag.';

  @override
  String get settingsNfcChipConfiguring => 'Настройка NFC-чипа';

  @override
  String get settingsQrCodeConfiguring => 'Настройка QR-кода';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get settingsVersionFallback => 'Pauza';

  @override
  String settingsVersionLabel(String version) {
    return 'Pauza v$version';
  }

  @override
  String get notFoundTitle => 'Страница не найдена';

  @override
  String get confirmButton => 'Подтвердить';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get okButton => 'OK';

  @override
  String get yesButton => 'Да';

  @override
  String weekDaysShort(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'mon': 'Пн',
      'tue': 'Вт',
      'wed': 'Ср',
      'thu': 'Чт',
      'fri': 'Пт',
      'sat': 'Сб',
      'sun': 'Вс',
      'other': 'Неизвестно',
    });
    return '$_temp0';
  }

  @override
  String weekDays(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'mon': 'Понедельник',
      'tue': 'Вторник',
      'wed': 'Среда',
      'thu': 'Четверг',
      'fri': 'Пятница',
      'sat': 'Суббота',
      'sun': 'Воскресенье',
      'other': 'Неизвестно',
    });
    return '$_temp0';
  }

  @override
  String get noButton => 'Нет';

  @override
  String get retryButton => 'Повторить';

  @override
  String get closeButton => 'Закрыть';

  @override
  String get nextButton => 'Далее';

  @override
  String get previousButton => 'Предыдущий';

  @override
  String get submitButton => 'Отправить';

  @override
  String get backButton => 'Назад';

  @override
  String get loadingLabel => 'Загрузка...';

  @override
  String get errorTitle => 'Что-то пошло не так';

  @override
  String get successTitle => 'Успех';

  @override
  String get searchPlaceholder => 'Поиск';

  @override
  String get emptyStateMessage => 'Пока нет данных';

  @override
  String get startButton => 'Начать';

  @override
  String get stopButton => 'Остановить';

  @override
  String get selectModeTitle => 'Выбор режима';

  @override
  String get addModeButton => 'Добавить режим';

  @override
  String get editModeButton => 'Изменить';

  @override
  String get deleteModeButton => 'Удалить';

  @override
  String get deleteModeTitle => 'Удалить режим?';

  @override
  String get deleteModeMessage => 'Это действие нельзя отменить.';

  @override
  String get comingSoonMessage => 'Скоро будет';

  @override
  String get noModesEmptyState => 'Режимов пока нет';

  @override
  String get selectMode => 'Выберите режим';

  @override
  String get alreadyBlocking => 'Блокировка уже включена';

  @override
  String get permissionUsageAccessTitle => 'Разрешите доступ к статистике';

  @override
  String get permissionUsageAccessBody =>
      'Pauza использует доступ к статистике, чтобы понимать, какие приложения активны, и применять ваши правила блокировки. Данные остаются на устройстве.';

  @override
  String get permissionAccessibilityTitle =>
      'Включите службу специальных возможностей';

  @override
  String get permissionAccessibilityBody =>
      'Pauza использует спец. возможности, чтобы сразу показывать экран блокировки при запуске запрещенного приложения.';

  @override
  String get permissionExactAlarmTitle => 'Разрешите точные будильники';

  @override
  String get permissionExactAlarmBody =>
      'Точные будильники делают расписания и таймеры паузы точными, чтобы блокировки начинались и заканчивались вовремя.';

  @override
  String get permissionFamilyControlsTitle =>
      'Разрешите Family Controls (Screen Time)';

  @override
  String get permissionFamilyControlsBody =>
      'Pauza использует авторизацию Family Controls / Screen Time для управления ограничениями приложений на iOS.';

  @override
  String get permissionsRequiredTitle => 'Требуются разрешения';

  @override
  String get permissionsRequiredBody =>
      'Чтобы помогать вам сохранять фокус и эффективно блокировать отвлекающие приложения, Pauza нужны разрешения из списка ниже. Ваши данные остаются на устройстве.';

  @override
  String get permissionUsageAccessShortBody =>
      'Отслеживание использования и лимитов';

  @override
  String get permissionAccessibilityShortBody =>
      'Определение и блокировка ограниченных приложений';

  @override
  String get permissionExactAlarmShortBody => 'Точное расписание и таймеры';

  @override
  String get permissionFamilyControlsShortBody =>
      'Управление ограничениями приложений на iOS';

  @override
  String permissionCurrentStatusLabel(String status) {
    return 'Текущий статус: $status';
  }

  @override
  String get permissionStatusGranted => 'Разрешено';

  @override
  String get permissionStatusDenied => 'Отклонено';

  @override
  String get permissionStatusRestricted => 'Ограничено';

  @override
  String get permissionStatusNotDetermined => 'Не определено';

  @override
  String get permissionOpenSettingsButton => 'Открыть настройки';

  @override
  String get permissionAllowAccessButton => 'Разрешить доступ';

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
  String get nfcChipHoldCardNearDevice =>
      'Hold your device near the NFC tag to scan';

  @override
  String get nfcChipConfigUidMissingError =>
      'This NFC tag cannot be linked because it does not provide an identifier.';

  @override
  String get nfcChipConfigScanFailed =>
      'Unable to link NFC tag. Please try again.';

  @override
  String get nfcChipConfigTagsTitle => 'Ваши NFC-метки';

  @override
  String get nfcChipConfigTagsBody =>
      'Управляйте привязанными NFC-метками. Эти метки служат физическими ключами для завершения фокус-сессий.';

  @override
  String get nfcChipConfigLinkNewTagButton => 'Привязать новую метку';

  @override
  String nfcChipConfigLinkedOnDate(String date) {
    return 'Привязано: $date';
  }

  @override
  String get nfcChipConfigRenameAction => 'Переименовать';

  @override
  String get nfcChipConfigDeleteAction => 'Удалить';

  @override
  String get nfcChipConfigRenameDialogTitle => 'Переименовать NFC-метку';

  @override
  String get nfcChipConfigRenameFieldLabel => 'Название метки';

  @override
  String get nfcChipConfigRenameFieldHint => 'Введите название метки';

  @override
  String get nfcChipConfigRenameSaveButton => 'Сохранить';

  @override
  String get nfcChipConfigNoTagsTitle => 'Пока нет привязанных меток';

  @override
  String get nfcChipConfigNoTagsBody =>
      'Привяжите первую NFC-метку для управления разблокировкой фокус-сессий.';

  @override
  String get qrCodeConfigTagsTitle => 'Your QR Codes';

  @override
  String get qrCodeConfigTagsBody =>
      'Manage your linked QR codes. Open any code to preview and use it for focus session unlocking.';

  @override
  String get qrCodeConfigGenerateNewCodeButton => 'Generate New QR';

  @override
  String qrCodeConfigLinkedOnDate(String date) {
    return 'Linked on $date';
  }

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
  String get qrCodeConfigNoCodesBody =>
      'Generate your first QR code to manage focus session unlocking.';

  @override
  String get qrCodeConfigPreviewDialogTitle => 'QR Code Preview';

  @override
  String get qrCodeConfigPreviewDialogBody =>
      'Show this QR code when you need to unlock your focus session.';

  @override
  String get qrCodeConfigActionFailed =>
      'Unable to update QR code configuration. Please try again.';

  @override
  String get qrCodeConfigGenerateFailed =>
      'Unable to generate a new QR code. Please try again.';

  @override
  String get qrCodeConfigRenameFailed =>
      'Unable to rename QR code. Please try again.';

  @override
  String get qrCodeConfigDeleteFailed =>
      'Unable to delete QR code. Please try again.';

  @override
  String blockedAppsCountLabel(int count) {
    return 'Заблокировано приложений: $count';
  }

  @override
  String get createModeTitle => 'Создать режим';

  @override
  String get editModeTitle => 'Изменить режим';

  @override
  String get modeTitleFieldLabel => 'Название';

  @override
  String get modeTextOnScreenFieldLabel => 'Текст на экране блокировки';

  @override
  String get modeDescriptionFieldLabel => 'Описание';

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
  String get modeEnabledLabel => 'Включен';

  @override
  String get modeBlockedAppsSectionTitle => 'Заблокированные приложения';

  @override
  String get modeBlockedAppsChooseButton => 'Выбрать приложения';

  @override
  String get modeBlockedAppsSubtitle => 'Настройте, что блокировать';

  @override
  String get modeBlockedAppsSearchLabel => 'Поиск приложений';

  @override
  String get modeBlockedAppsRequiredError => 'Выберите хотя бы одно приложение';

  @override
  String modeBlockedAppsSelectedCountLabel(int count) {
    return 'Выбрано приложений: $count';
  }

  @override
  String get modeScheduleTitle => 'Расписание (необязательно)';

  @override
  String get modeScheduleStartTimeLabel => 'Время начала';

  @override
  String get modeScheduleEndTimeLabel => 'Время окончания';

  @override
  String get modeScheduleDaysRequiredError => 'Выберите хотя бы один день';

  @override
  String get modeStrictnessTitle => 'Строгость';

  @override
  String get modeAllowedPausesTitle => 'Разрешенные паузы';

  @override
  String get modeAllowedPausesSubtitle => 'Короткие перерывы во время сессии';

  @override
  String get modeMinimumDurationTitle => 'Минимальная длительность';

  @override
  String get modeMinimumDurationSubtitle =>
      'Необязательно. Сессию нельзя завершить раньше этого времени.';

  @override
  String get modeMinimumDurationSetButton => 'Установить длительность';

  @override
  String get modeMinimumDurationClearButton => 'Очистить';

  @override
  String get modeMinimumDurationNotSet => 'Не задано';

  @override
  String modeMinimumDurationValueMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get modeEndingPausingScenarioTitle => 'Сценарий завершения / паузы';

  @override
  String get modeEndingPausingScenarioSubtitle =>
      'Выберите, как можно завершить или поставить на паузу этот режим.';

  @override
  String get modeEndingPausingScenarioNfc => 'NFC';

  @override
  String get modeEndingPausingScenarioQrCode => 'QR';

  @override
  String get modeEndingPausingScenarioManual => 'Вручную';

  @override
  String get modeEndingPausingScenarioNfcDisabled =>
      'NFC не поддерживается на этом устройстве.';

  @override
  String modeAllowedPausesOutOfRangeError(int min, int max) {
    return 'Разрешенные паузы должны быть от $min до $max';
  }

  @override
  String get modeDeleteFocusButton => 'Удалить режим фокуса';

  @override
  String get modeSaveButton => 'Сохранить режим';

  @override
  String get modeRequiredFieldError => 'Поле обязательно';

  @override
  String get modeLoadFailedMessage => 'Не удалось загрузить данные режима';

  @override
  String get modeSaveFailedMessage => 'Не удалось сохранить режим';

  @override
  String get modeDeleteFailedMessage => 'Не удалось удалить режим';

  @override
  String get modeAppsLoadFailedMessage => 'Не удалось загрузить приложения';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get selectAppsTitle => 'Select apps';

  @override
  String get selectAppsForPauzaTitle => 'Выберите приложения для Pauza';

  @override
  String get doneButton => 'Done';

  @override
  String get selectButton => 'Выбрать';

  @override
  String appsSelectedCountLabel(int count) {
    return '$count выбрано';
  }

  @override
  String get allAppsCategory => 'Все приложения';

  @override
  String get selectAllButton => 'Выбрать все';

  @override
  String get deselectAllButton => 'Снять выбор';

  @override
  String get otherAppsCategory => 'Другое';

  @override
  String homeGreeting(String hour) {
    String _temp0 = intl.Intl.selectLogic(hour, {
      '0': 'Доброй ночи',
      '1': 'Доброй ночи',
      '2': 'Доброй ночи',
      '3': 'Доброй ночи',
      '4': 'Доброй ночи',
      '5': 'Доброе утро',
      '6': 'Доброе утро',
      '7': 'Доброе утро',
      '8': 'Доброе утро',
      '9': 'Доброе утро',
      '10': 'Доброе утро',
      '11': 'Доброе утро',
      '12': 'Добрый день',
      '13': 'Добрый день',
      '14': 'Добрый день',
      '15': 'Добрый день',
      '16': 'Добрый день',
      '17': 'Добрый вечер',
      '18': 'Добрый вечер',
      '19': 'Добрый вечер',
      '20': 'Добрый вечер',
      '21': 'Добрый вечер',
      '22': 'Доброй ночи',
      '23': 'Доброй ночи',
      'other': 'Доброй ночи',
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
  String get homePauseBlockedByLimit => 'Достигнут лимит пауз для этой сессии.';

  @override
  String homeActionBlockedByMinimumDuration(String remaining) {
    return 'Действие недоступно. Попробуйте через $remaining.';
  }

  @override
  String get homeActionBlockedModeUnavailable =>
      'Данные режима недоступны. Обновите состояние и попробуйте снова.';

  @override
  String get homeActionScenarioProofRequired =>
      'Для этого действия нужно сканирование.';

  @override
  String get homeActionNfcMissingIdentifier =>
      'Эта NFC-метка не может быть использована, потому что у нее нет идентификатора.';

  @override
  String get homeActionNfcNotLinked =>
      'Эта NFC-метка не привязана. Используйте привязанную метку, чтобы продолжить.';

  @override
  String get homeActionQrInvalid =>
      'Неверный QR-код. Попробуйте отсканировать привязанный QR-код Pauza.';

  @override
  String get homeActionQrNotLinked =>
      'Этот QR-код не привязан. Используйте привязанный код, чтобы продолжить.';

  @override
  String get homeActionStartNfcConfigRequired =>
      'Чтобы начать эту сессию, привяжите хотя бы одну NFC-метку в настройках.';

  @override
  String get homeActionStartQrConfigRequired =>
      'Чтобы начать эту сессию, привяжите хотя бы один QR-код в настройках.';

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
  String get homeCurrentModeLabel => 'Текущий режим';

  @override
  String homeDayStreakLabel(int count) {
    return '$count дней подряд';
  }

  @override
  String homeDurationHoursMinutesLabel(int hours, int minutes) {
    return '$hoursч $minutesм';
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

  @override
  String get authTagline => 'Фокус и благополучие';

  @override
  String get authEmailAddress => 'Адрес электронной почты';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authLogIn => 'Войти';

  @override
  String get authOtpTitle => 'Подтвердите Email';

  @override
  String get authOtpSubtitlePrefix =>
      'Введите 6-значный код, который мы отправили на ваш email ';

  @override
  String get authOtpSubtitleSuffix => '.';

  @override
  String get authOtpVerifyButton => 'Подтвердить';

  @override
  String get authOtpDidNotReceiveCode => 'Не получили код?';

  @override
  String get authOtpResendCode => 'Отправить код снова';

  @override
  String authOtpAvailableInLabel(String minutes, String seconds) {
    return 'Доступно через $minutes:$seconds';
  }

  @override
  String get authValidationRequired => 'Это поле обязательно';

  @override
  String get authValidationInvalidEmail => 'Введите корректный email';

  @override
  String get authFailureInvalidCredentials => 'Неверный email или пароль.';

  @override
  String get authFailureInvalidOtp => 'Неверный код подтверждения.';

  @override
  String get authFailureOtpChallengeMissing =>
      'Сессия подтверждения истекла. Попробуйте снова.';

  @override
  String get authFailureStorage =>
      'Не удалось получить доступ к защищенному хранилищу.';

  @override
  String get authFailureUnknown => 'Не удалось войти. Попробуйте снова.';
}
