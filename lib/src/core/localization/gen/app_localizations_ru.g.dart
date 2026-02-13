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
  String get modeBlockedAppsSearchLabel => 'Поиск приложений';

  @override
  String get modeBlockedAppsRequiredError => 'Выберите хотя бы одно приложение';

  @override
  String modeBlockedAppsSelectedCountLabel(int count) {
    return 'Выбрано приложений: $count';
  }

  @override
  String get modeRequiredFieldError => 'Поле обязательно';

  @override
  String get modeLoadFailedMessage => 'Не удалось загрузить данные режима';

  @override
  String get modeSaveFailedMessage => 'Не удалось сохранить режим';

  @override
  String get modeAppsLoadFailedMessage => 'Не удалось загрузить приложения';

  @override
  String get saveButton => 'Сохранить';
}
