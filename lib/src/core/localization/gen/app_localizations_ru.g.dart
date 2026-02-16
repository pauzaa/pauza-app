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
}
