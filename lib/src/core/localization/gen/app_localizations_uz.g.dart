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
  String get statsTitle => 'Statistika';

  @override
  String get leaderboardTitle => 'Reyting';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileDisplayNameFallback => 'Noma\'lum foydalanuvchi';

  @override
  String get profileUsernameFallback => 'username';

  @override
  String get profileEditInfoNavTitle => 'Profilni tahrirlash';

  @override
  String get profileSettingsNavTitle => 'Sozlamalar';

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
  String get selectMode => 'Rejimni tanlang';

  @override
  String get alreadyBlocking => 'Bloklanish allaqachon yoqilgan';

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
  String get permissionsRequiredTitle => 'Ruxsatlar talab qilinadi';

  @override
  String get permissionsRequiredBody =>
      'Diqqatingizni jamlash va chalg\'ituvchi ilovalarni samarali bloklash uchun Pauza\'ga quyida keltirilgan ruxsatlar kerak. Ma\'lumotlaringiz qurilmangizda qoladi.';

  @override
  String get permissionUsageAccessShortBody =>
      'Foydalanishni kuzatish va limitlarni qo\'llash';

  @override
  String get permissionAccessibilityShortBody =>
      'Cheklangan ilovalarni aniqlash va bloklash';

  @override
  String get permissionExactAlarmShortBody =>
      'Jadval va taymerlarni aniq ishlatish';

  @override
  String get permissionFamilyControlsShortBody =>
      'iOS\'da ilova cheklovlarini boshqarish';

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
  String get modeEnabledLabel => 'Yoqilgan';

  @override
  String get modeBlockedAppsSectionTitle => 'Bloklanadigan ilovalar';

  @override
  String get modeBlockedAppsChooseButton => 'Ilovalarni tanlash';

  @override
  String get modeBlockedAppsSubtitle => 'Nimani bloklashni sozlang';

  @override
  String get modeBlockedAppsSearchLabel => 'Ilovalarni qidirish';

  @override
  String get modeBlockedAppsRequiredError => 'Kamida bitta ilovani tanlang';

  @override
  String modeBlockedAppsSelectedCountLabel(int count) {
    return 'Tanlangan ilovalar: $count';
  }

  @override
  String get modeScheduleTitle => 'Jadval (ixtiyoriy)';

  @override
  String get modeScheduleStartTimeLabel => 'Boshlanish vaqti';

  @override
  String get modeScheduleEndTimeLabel => 'Tugash vaqti';

  @override
  String get modeScheduleDaysRequiredError => 'Kamida bitta kunni tanlang';

  @override
  String get modeStrictnessTitle => 'Qat\'iylik';

  @override
  String get modeAllowedPausesTitle => 'Ruxsat etilgan tanaffuslar';

  @override
  String get modeAllowedPausesSubtitle => 'Sessiya davomida qisqa tanaffuslar';

  @override
  String modeAllowedPausesOutOfRangeError(int min, int max) {
    return 'Ruxsat etilgan tanaffuslar $min va $max oralig\'ida bo\'lishi kerak';
  }

  @override
  String get modeDeleteFocusButton => 'Fokus rejimini o\'chirish';

  @override
  String get modeSaveButton => 'Rejimni saqlash';

  @override
  String get modeRequiredFieldError => 'Bu maydon majburiy';

  @override
  String get modeLoadFailedMessage => 'Rejim ma\'lumotlarini yuklab bo\'lmadi';

  @override
  String get modeSaveFailedMessage => 'Rejimni saqlab bo\'lmadi';

  @override
  String get modeDeleteFailedMessage => 'Rejimni o\'chirib bo\'lmadi';

  @override
  String get modeAppsLoadFailedMessage => 'Ilovalarni yuklab bo\'lmadi';

  @override
  String get saveButton => 'Saqlash';

  @override
  String get selectAppsTitle => 'Select apps';

  @override
  String get selectAppsForPauzaTitle => 'Pauza uchun ilovalarni tanlang';

  @override
  String get doneButton => 'Done';

  @override
  String get selectButton => 'Tanlash';

  @override
  String appsSelectedCountLabel(int count) {
    return '$count ta tanlandi';
  }

  @override
  String get allAppsCategory => 'Barcha ilovalar';

  @override
  String get selectAllButton => 'Barchasini tanlash';

  @override
  String get deselectAllButton => 'Tanlovni bekor qilish';

  @override
  String get otherAppsCategory => 'Boshqa';

  @override
  String homeGreeting(String hour) {
    String _temp0 = intl.Intl.selectLogic(hour, {
      '0': 'Xayrli tun',
      '1': 'Xayrli tun',
      '2': 'Xayrli tun',
      '3': 'Xayrli tun',
      '4': 'Xayrli tun',
      '5': 'Xayrli tong',
      '6': 'Xayrli tong',
      '7': 'Xayrli tong',
      '8': 'Xayrli tong',
      '9': 'Xayrli tong',
      '10': 'Xayrli tong',
      '11': 'Xayrli tong',
      '12': 'Xayrli kun',
      '13': 'Xayrli kun',
      '14': 'Xayrli kun',
      '15': 'Xayrli kun',
      '16': 'Xayrli kun',
      '17': 'Xayrli kech',
      '18': 'Xayrli kech',
      '19': 'Xayrli kech',
      '20': 'Xayrli kech',
      '21': 'Xayrli kech',
      '22': 'Xayrli tun',
      '23': 'Xayrli tun',
      'other': 'Xayrli tun',
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
  String get homeCurrentModeLabel => 'Joriy rejim';

  @override
  String homeDayStreakLabel(int count) {
    return '$count kunlik seriya';
  }

  @override
  String homeDurationHoursMinutesLabel(int hours, int minutes) {
    return '${hours}s ${minutes}d';
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
  String get authTagline => 'Diqqat va farovonlik';

  @override
  String get authEmailAddress => 'Email manzili';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPassword => 'Parol';

  @override
  String get authForgotPassword => 'Parolni unutdingizmi?';

  @override
  String get authLogIn => 'Kirish';

  @override
  String get authValidationRequired => 'Bu maydon majburiy';

  @override
  String get authValidationInvalidEmail => 'To\'g\'ri email manzilini kiriting';

  @override
  String get authFailureInvalidCredentials => 'Email yoki parol noto\'g\'ri.';

  @override
  String get authFailureInvalidOtp => 'Tasdiqlash kodi noto\'g\'ri.';

  @override
  String get authFailureOtpChallengeMissing =>
      'Tasdiqlash sessiyasi tugagan. Qayta urinib ko\'ring.';

  @override
  String get authFailureStorage => 'Xavfsiz xotiraga kirib bo\'lmadi.';

  @override
  String get authFailureUnknown =>
      'Kirish amalga oshmadi. Qayta urinib ko\'ring.';
}

/// The translations for Uzbek, using the Cyrillic script (`uz_Cyrl`).
class AppLocalizationsUzCyrl extends AppLocalizationsUz {
  AppLocalizationsUzCyrl() : super('uz_Cyrl');

  @override
  String get appName => 'Pauza';

  @override
  String get homeTitle => 'Бош саҳифа';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get leaderboardTitle => 'Рейтинг';

  @override
  String get profileTitle => 'Профил';

  @override
  String get profileDisplayNameFallback => 'Номаълум фойдаланувчи';

  @override
  String get profileUsernameFallback => 'username';

  @override
  String get profileEditInfoNavTitle => 'Профилни таҳрирлаш';

  @override
  String get profileSettingsNavTitle => 'Созламалар';

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
  String get selectMode => 'Режимни танланг';

  @override
  String get alreadyBlocking => 'Блокланиш аллақачон ёқилган';

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
  String get permissionsRequiredTitle => 'Рухсатлар талаб қилинади';

  @override
  String get permissionsRequiredBody =>
      'Диққатингизни жамлаш ва чалғитувчи иловаларни самарали блоклаш учун Pauza\'га қуйида келтирилган рухсатлар керак. Маълумотларингиз қурилмангизда қолади.';

  @override
  String get permissionUsageAccessShortBody =>
      'Фойдаланишни кузатиш ва лимитларни қўллаш';

  @override
  String get permissionAccessibilityShortBody =>
      'Чекланган иловаларни аниқлаш ва блоклаш';

  @override
  String get permissionExactAlarmShortBody =>
      'Жадвал ва таймерларни аниқ ишлатиш';

  @override
  String get permissionFamilyControlsShortBody =>
      'iOS\'да илова чекловларини бошқариш';

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
  String get modeBlockedAppsSubtitle => 'Нимани блоклашни созланг';

  @override
  String get modeBlockedAppsSearchLabel => 'Иловаларни қидириш';

  @override
  String get modeBlockedAppsRequiredError => 'Камида битта иловани танланг';

  @override
  String modeBlockedAppsSelectedCountLabel(int count) {
    return 'Танланган иловалар: $count';
  }

  @override
  String get modeScheduleTitle => 'Жадвал (ихтиёрий)';

  @override
  String get modeScheduleStartTimeLabel => 'Бошланиш вақти';

  @override
  String get modeScheduleEndTimeLabel => 'Тугаш вақти';

  @override
  String get modeScheduleDaysRequiredError => 'Камида битта кунни танланг';

  @override
  String get modeStrictnessTitle => 'Қатъийлик';

  @override
  String get modeAllowedPausesTitle => 'Рухсат этилган танаффуслар';

  @override
  String get modeAllowedPausesSubtitle => 'Сессия давомида қисқа танаффуслар';

  @override
  String modeAllowedPausesOutOfRangeError(int min, int max) {
    return 'Рухсат этилган танаффуслар $min ва $max оралиғида бўлиши керак';
  }

  @override
  String get modeDeleteFocusButton => 'Фокус режимини ўчириш';

  @override
  String get modeSaveButton => 'Режимни сақлаш';

  @override
  String get modeRequiredFieldError => 'Бу майдон мажбурий';

  @override
  String get modeLoadFailedMessage => 'Режим маълумотларини юклаб бўлмади';

  @override
  String get modeSaveFailedMessage => 'Режимни сақлаб бўлмади';

  @override
  String get modeDeleteFailedMessage => 'Режимни ўчириб бўлмади';

  @override
  String get modeAppsLoadFailedMessage => 'Иловаларни юклаб бўлмади';

  @override
  String get saveButton => 'Сақлаш';

  @override
  String get selectAppsForPauzaTitle => 'Pauza учун иловаларни танланг';

  @override
  String get selectButton => 'Танлаш';

  @override
  String appsSelectedCountLabel(int count) {
    return '$count та танланди';
  }

  @override
  String get allAppsCategory => 'Барча иловалар';

  @override
  String get selectAllButton => 'Барчасини танлаш';

  @override
  String get deselectAllButton => 'Танловни бекор қилиш';

  @override
  String get otherAppsCategory => 'Бошқа';

  @override
  String homeGreeting(String hour) {
    String _temp0 = intl.Intl.selectLogic(hour, {
      '0': 'Хайрли тун',
      '1': 'Хайрли тун',
      '2': 'Хайрли тун',
      '3': 'Хайрли тун',
      '4': 'Хайрли тун',
      '5': 'Хайрли тонг',
      '6': 'Хайрли тонг',
      '7': 'Хайрли тонг',
      '8': 'Хайрли тонг',
      '9': 'Хайрли тонг',
      '10': 'Хайрли тонг',
      '11': 'Хайрли тонг',
      '12': 'Хайрли кун',
      '13': 'Хайрли кун',
      '14': 'Хайрли кун',
      '15': 'Хайрли кун',
      '16': 'Хайрли кун',
      '17': 'Хайрли кеч',
      '18': 'Хайрли кеч',
      '19': 'Хайрли кеч',
      '20': 'Хайрли кеч',
      '21': 'Хайрли кеч',
      '22': 'Хайрли тун',
      '23': 'Хайрли тун',
      'other': 'Хайрли тун',
    });
    return '$_temp0';
  }

  @override
  String get homeDashboardTitle => 'Pauza Dashboard';

  @override
  String get homePauzaSessionLabel => 'Pauza Session';

  @override
  String get homeCurrentModeLabel => 'Жорий режим';

  @override
  String homeDayStreakLabel(int count) {
    return '$count кунлик серия';
  }

  @override
  String homeDurationHoursMinutesLabel(int hours, int minutes) {
    return '$hoursс $minutesд';
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
  String get authTagline => 'Диққат ва фаровонлик';

  @override
  String get authEmailAddress => 'Email манзили';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPassword => 'Парол';

  @override
  String get authForgotPassword => 'Паролни унутдингизми?';

  @override
  String get authLogIn => 'Кириш';

  @override
  String get authValidationRequired => 'Бу майдон мажбурий';

  @override
  String get authValidationInvalidEmail => 'Тўғри email манзилини киритинг';

  @override
  String get authFailureInvalidCredentials => 'Email ёки парол нотўғри.';

  @override
  String get authFailureInvalidOtp => 'Тасдиқлаш коди нотўғри.';

  @override
  String get authFailureOtpChallengeMissing =>
      'Тасдиқлаш сессияси тугаган. Қайта уриниб кўринг.';

  @override
  String get authFailureStorage => 'Хавфсиз хотирага кириб бўлмади.';

  @override
  String get authFailureUnknown => 'Кириш амалга ошмади. Қайта уриниб кўринг.';
}
