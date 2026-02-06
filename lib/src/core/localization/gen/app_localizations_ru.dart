// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

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
      'Pauza нужен доступ к статистике, чтобы видеть активность приложений и применять блокировки.';

  @override
  String get permissionAccessibilityTitle =>
      'Включите службу специальных возможностей';

  @override
  String get permissionAccessibilityBody =>
      'Pauza нужна служба специальных возможностей, чтобы определять запуск заблокированных приложений.';

  @override
  String get permissionFamilyControlsTitle => 'Разрешите Family Controls';

  @override
  String get permissionFamilyControlsBody =>
      'Pauza нужна авторизация Family Controls для управления ограничениями приложений на iOS.';

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
}
