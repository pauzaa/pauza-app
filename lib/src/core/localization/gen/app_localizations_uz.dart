// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

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
      'Pauza ilova faolligini ko\'rish va bloklash qoidalarini qo\'llash uchun Usage Access ruxsatiga muhtoj.';

  @override
  String get permissionAccessibilityTitle => 'Accessibility xizmatini yoqing';

  @override
  String get permissionAccessibilityBody =>
      'Pauza bloklangan ilovalar ochilganda aniqlash uchun Accessibility xizmatiga muhtoj.';

  @override
  String get permissionFamilyControlsTitle =>
      'Family Controls ruxsatini bering';

  @override
  String get permissionFamilyControlsBody =>
      'Pauza iOS\'da ilova cheklovlarini boshqarish uchun Family Controls ruxsatiga muhtoj.';

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
}
