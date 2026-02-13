// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'Pauza';

  @override
  String get homeTitle => 'Bosh sahifa';

  @override
  String get notFoundTitle => 'Sahifa topilmadi';

  @override
  String get confirmButton => 'Tasdiqlash';

  @override
  String get cancelButton => 'Bekor qilish';

  @override
  String get okButton => 'OK';

  @override
  String get yesButton => 'Ha';

  @override
  String weekDaysShort(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'mon': 'Du',
      'tue': 'Se',
      'wed': 'Ch',
      'thu': 'Pa',
      'fri': 'Ju',
      'sat': 'Sh',
      'sun': 'Ya',
      'other': 'Noma\'lum',
    });
    return '$_temp0';
  }

  @override
  String weekDays(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'mon': 'Dushanba',
      'tue': 'Seshanba',
      'wed': 'Chorshanba',
      'thu': 'Payshanba',
      'fri': 'Juma',
      'sat': 'Shanba',
      'sun': 'Yakshanba',
      'other': 'Noma\'lum',
    });
    return '$_temp0';
  }

  @override
  String get noButton => 'Yo\'q';

  @override
  String get retryButton => 'Qaytadan urinib ko\'rish';

  @override
  String get closeButton => 'Yopish';

  @override
  String get nextButton => 'Keyingi';

  @override
  String get previousButton => 'Oldingi';

  @override
  String get submitButton => 'Yuborish';

  @override
  String get backButton => 'Ortga';

  @override
  String get loadingLabel => 'Yuklanmoqda...';

  @override
  String get errorTitle => 'Xatolik yuz berdi';

  @override
  String get successTitle => 'Muvaffaqiyat';

  @override
  String get searchPlaceholder => 'Qidirish';

  @override
  String get emptyStateMessage => 'Ko\'rsatish uchun elementlar yo\'q';

  @override
  String get startButton => 'Boshlash';

  @override
  String get stopButton => 'To\'xtatish';

  @override
  String get selectModeTitle => 'Rejimni tanlang';

  @override
  String get addModeButton => 'Yangi rejim qo\'shish';

  @override
  String get editModeButton => 'Tahrirlash';

  @override
  String get deleteModeButton => 'O\'chirish';

  @override
  String get deleteModeTitle => 'Rejim o\'chirilsinmi?';

  @override
  String get deleteModeMessage => 'Bu amalni ortga qaytarib bo\'lmaydi.';

  @override
  String get comingSoonMessage => 'Tez orada';

  @override
  String get noModesEmptyState => 'Hozircha rejimlar yo\'q';

  @override
  String get permissionUsageAccessTitle => 'Foydalanish ruxsatini yoqing';

  @override
  String get permissionUsageAccessBody =>
      'Pauza Usage Access orqali qaysi ilovalar faol ekanini biladi va bloklash qoidalarini qo\'llaydi. Ma\'lumotlar qurilmangizda qoladi.';

  @override
  String get permissionAccessibilityTitle => 'Accessibility xizmatini yoqing';

  @override
  String get permissionAccessibilityBody =>
      'Pauza bloklangan ilova ochilganda darhol bloklash ekranini ko\'rsatish uchun Accessibility xizmatidan foydalanadi.';

  @override
  String get permissionExactAlarmTitle => 'Aniq signal ruxsatini bering';

  @override
  String get permissionExactAlarmBody =>
      'Aniq signal (exact alarm) jadval va pauza taymerlarini aniq ishlatib, bloklashni o\'z vaqtida boshlatadi va tugatadi.';

  @override
  String get permissionFamilyControlsTitle =>
      'Family Controls (Screen Time) ruxsatini bering';

  @override
  String get permissionFamilyControlsBody =>
      'Pauza iOS\'da ilova cheklovlarini boshqarish uchun Family Controls / Screen Time ruxsatidan foydalanadi.';

  @override
  String permissionCurrentStatusLabel(String status) {
    return 'Joriy holat: $status';
  }

  @override
  String get permissionStatusGranted => 'Ruxsat berilgan';

  @override
  String get permissionStatusDenied => 'Rad etilgan';

  @override
  String get permissionStatusRestricted => 'Cheklangan';

  @override
  String get permissionStatusNotDetermined => 'Aniqlanmagan';

  @override
  String get permissionOpenSettingsButton => 'Sozlamalarni ochish';

  @override
  String get permissionAllowAccessButton => 'Ruxsat berish';

  @override
  String blockedAppsCountLabel(int count) {
    return 'Bloklangan ilovalar: $count';
  }

  @override
  String get createModeTitle => 'Rejim yaratish';

  @override
  String get editModeTitle => 'Rejimni tahrirlash';

  @override
  String get modeTitleFieldLabel => 'Nomi';

  @override
  String get modeTextOnScreenFieldLabel => 'Bloklash ekranidagi matn';

  @override
  String get modeDescriptionFieldLabel => 'Tavsif';

  @override
  String get modeEnabledLabel => 'Yoqilgan';

  @override
  String get modeBlockedAppsSectionTitle => 'Bloklanadigan ilovalar';

  @override
  String get modeBlockedAppsChooseButton => 'Ilovalarni tanlash';

  @override
  String get modeBlockedAppsSearchLabel => 'Ilovalarni qidirish';

  @override
  String get modeBlockedAppsRequiredError => 'Kamida bitta ilovani tanlang';

  @override
  String modeBlockedAppsSelectedCountLabel(int count) {
    return 'Tanlangan ilovalar: $count';
  }

  @override
  String get modeRequiredFieldError => 'Bu maydon majburiy';

  @override
  String get modeLoadFailedMessage => 'Rejim ma\'lumotlarini yuklab bo\'lmadi';

  @override
  String get modeSaveFailedMessage => 'Rejimni saqlab bo\'lmadi';

  @override
  String get modeAppsLoadFailedMessage => 'Ilovalarni yuklab bo\'lmadi';

  @override
  String get saveButton => 'Saqlash';
}

/// The translations for Uzbek, using the Cyrillic script (`uz_Cyrl`).
class AppLocalizationsUzCyrl extends AppLocalizationsUz {
  AppLocalizationsUzCyrl() : super('uz_Cyrl');

  @override
  String get appName => 'Pauza';

  @override
  String get homeTitle => 'Бош саҳифа';

  @override
  String get notFoundTitle => 'Саҳифа топилмади';

  @override
  String get confirmButton => 'Тасдиқлаш';

  @override
  String get cancelButton => 'Бекор қилиш';

  @override
  String get okButton => 'OK';

  @override
  String get yesButton => 'Ҳа';

  @override
  String weekDaysShort(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'mon': 'Ду',
      'tue': 'Се',
      'wed': 'Чо',
      'thu': 'Па',
      'fri': 'Жу',
      'sat': 'Ша',
      'sun': 'Як',
      'other': 'Номаълум',
    });
    return '$_temp0';
  }

  @override
  String weekDays(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'mon': 'Душанба',
      'tue': 'Сешанба',
      'wed': 'Чоршанба',
      'thu': 'Пайшанба',
      'fri': 'Жума',
      'sat': 'Шанба',
      'sun': 'Якшанба',
      'other': 'Номаълум',
    });
    return '$_temp0';
  }

  @override
  String get noButton => 'Йўқ';

  @override
  String get retryButton => 'Қайтадан уриниб кўриш';

  @override
  String get closeButton => 'Ёпиш';

  @override
  String get nextButton => 'Кейинги';

  @override
  String get previousButton => 'Олдинги';

  @override
  String get submitButton => 'Юбориш';

  @override
  String get backButton => 'Ортга';

  @override
  String get loadingLabel => 'Юкланмоқда...';

  @override
  String get errorTitle => 'Хатолик юз берди';

  @override
  String get successTitle => 'Муваффақият';

  @override
  String get searchPlaceholder => 'Қидириш';

  @override
  String get emptyStateMessage => 'Кўрсатиш учун элементлар йўқ';

  @override
  String get startButton => 'Бошлаш';

  @override
  String get stopButton => 'Тўхтатиш';

  @override
  String get selectModeTitle => 'Режимни танланг';

  @override
  String get addModeButton => 'Янги режим қўшиш';

  @override
  String get editModeButton => 'Таҳрирлаш';

  @override
  String get deleteModeButton => 'Ўчириш';

  @override
  String get deleteModeTitle => 'Режим ўчирилсинми?';

  @override
  String get deleteModeMessage => 'Бу амални ортга қайтариб бўлмайди.';

  @override
  String get comingSoonMessage => 'Тез орада';

  @override
  String get noModesEmptyState => 'Ҳозирча режимлар йўқ';

  @override
  String get permissionUsageAccessTitle => 'Фойдаланиш рухсатини ёнг';

  @override
  String get permissionUsageAccessBody =>
      'Pauza Usage Access орқали қайси иловалар фаол эканини билади ва блоклаш қоидаларини қўллайди. Маълумотлар қурилмангизда қолади.';

  @override
  String get permissionAccessibilityTitle => 'Accessibility хизматини ёнг';

  @override
  String get permissionAccessibilityBody =>
      'Pauza блокланган илова очилганда дарҳол блоклаш экранини кўрсатиш учун Accessibility хизматидан фойдаланади.';

  @override
  String get permissionExactAlarmTitle => 'Аниқ сигнал рухсатини беринг';

  @override
  String get permissionExactAlarmBody =>
      'Аниқ сигнал (exact alarm) жадвал ва пауза таймерларини аниқ ишлатиб, блоклашни ўз вақтида бошлади ва тугатади.';

  @override
  String get permissionFamilyControlsTitle =>
      'Family Controls (Screen Time) рухсатини беринг';

  @override
  String get permissionFamilyControlsBody =>
      'Pauza iOS\'да илова чекловларини бошқариш учун Family Controls / Screen Time рухсатидан фойдаланади.';

  @override
  String permissionCurrentStatusLabel(String status) {
    return 'Жорий ҳолат: $status';
  }

  @override
  String get permissionStatusGranted => 'Рухсат берилган';

  @override
  String get permissionStatusDenied => 'Рад этилган';

  @override
  String get permissionStatusRestricted => 'Чекланган';

  @override
  String get permissionStatusNotDetermined => 'Аниқланмаган';

  @override
  String get permissionOpenSettingsButton => 'Созламаларни очиш';

  @override
  String get permissionAllowAccessButton => 'Рухсат бериш';

  @override
  String blockedAppsCountLabel(int count) {
    return 'Блокланган иловалар: $count';
  }

  @override
  String get createModeTitle => 'Режим яратиш';

  @override
  String get editModeTitle => 'Режимни таҳрирлаш';

  @override
  String get modeTitleFieldLabel => 'Номи';

  @override
  String get modeTextOnScreenFieldLabel => 'Блоклаш экранидаги матн';

  @override
  String get modeDescriptionFieldLabel => 'Тавсиф';

  @override
  String get modeEnabledLabel => 'Ёқилган';

  @override
  String get modeBlockedAppsSectionTitle => 'Блокланадиган иловалар';

  @override
  String get modeBlockedAppsChooseButton => 'Иловаларни танлаш';

  @override
  String get modeBlockedAppsSearchLabel => 'Иловаларни қидириш';

  @override
  String get modeBlockedAppsRequiredError => 'Камида битта иловани танланг';

  @override
  String modeBlockedAppsSelectedCountLabel(int count) {
    return 'Танланган иловалар: $count';
  }

  @override
  String get modeRequiredFieldError => 'Бу майдон мажбурий';

  @override
  String get modeLoadFailedMessage => 'Режим маълумотларини юклаб бўлмади';

  @override
  String get modeSaveFailedMessage => 'Режимни сақлаб бўлмади';

  @override
  String get modeAppsLoadFailedMessage => 'Иловаларни юклаб бўлмади';

  @override
  String get saveButton => 'Сақлаш';
}
