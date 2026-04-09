// dart format width=120

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

class $ConfigGen {
  const $ConfigGen();

  /// File path: config/AGENTS.md
  String get agents => 'config/AGENTS.md';

  /// File path: config/prod.json
  String get prod => 'config/prod.json';

  /// File path: config/test.json
  String get test => 'config/test.json';

  /// List of all assets
  List<String> get values => [agents, prod, test];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/logo
  $AssetsImagesLogoGen get logo => const $AssetsImagesLogoGen();

  /// Directory path: assets/images/onboarding
  $AssetsImagesOnboardingGen get onboarding => const $AssetsImagesOnboardingGen();
}

class $AssetsImagesLogoGen {
  const $AssetsImagesLogoGen();

  /// File path: assets/images/logo/puaza_svg.svg
  String get puazaSvg => 'assets/images/logo/puaza_svg.svg';

  /// List of all assets
  List<String> get values => [puazaSvg];
}

class $AssetsImagesOnboardingGen {
  const $AssetsImagesOnboardingGen();

  /// File path: assets/images/onboarding/onboarding_focus.svg
  String get onboardingFocus => 'assets/images/onboarding/onboarding_focus.svg';

  /// File path: assets/images/onboarding/onboarding_modes.svg
  String get onboardingModes => 'assets/images/onboarding/onboarding_modes.svg';

  /// File path: assets/images/onboarding/onboarding_social.svg
  String get onboardingSocial => 'assets/images/onboarding/onboarding_social.svg';

  /// File path: assets/images/onboarding/onboarding_stats.svg
  String get onboardingStats => 'assets/images/onboarding/onboarding_stats.svg';

  /// File path: assets/images/onboarding/onboarding_streaks.svg
  String get onboardingStreaks => 'assets/images/onboarding/onboarding_streaks.svg';

  /// File path: assets/images/onboarding/onboarding_unlock.svg
  String get onboardingUnlock => 'assets/images/onboarding/onboarding_unlock.svg';

  /// List of all assets
  List<String> get values => [
    onboardingFocus,
    onboardingModes,
    onboardingSocial,
    onboardingStats,
    onboardingStreaks,
    onboardingUnlock,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $ConfigGen config = $ConfigGen();
}
