import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/theme/color_theme.dart';
import 'package:pauza_ui_kit/src/theme/pauza_text_theme.dart';

PauzaColorScheme get _lightColors => const PauzaColorScheme(
  primary: Color(0xFF800020),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFFFD9DF),
  onPrimaryContainer: Color(0xFF3A0010),
  secondary: Color(0xFF9C2640),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFFFD9DE),
  onSecondaryContainer: Color(0xFF3F0018),
  error: Color(0xFFBA1A1A),
  onError: Colors.white,
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  success: Color(0xFF2E7D32),
  onSuccess: Colors.white,
  successContainer: Color(0xFFC8E6C9),
  onSuccessContainer: Color(0xFF0B2E0E),
  warning: Color(0xFFED8B00),
  onWarning: Colors.white,
  warningContainer: Color(0xFFFFE0B2),
  onWarningContainer: Color(0xFF4B2800),
  surfaceDim: Color(0xFFEFE0E3),
  surface: Colors.white,
  surfaceBright: Color(0xFFFDF8F8),
  surfaceContainerLowest: Colors.white,
  surfaceContainerLow: Color(0xFFFDF8F8),
  surfaceContainer: Color(0xFFF7EEF0),
  surfaceContainerHigh: Color(0xFFF3E7EA),
  surfaceContainerHighest: Color(0xFFEFE0E3),
  onSurface: Color(0xFF22191B),
  onSurfaceVariant: Color(0xFF524346),
  outline: Color(0xFF857376),
  outlineVariant: Color(0xFFD8C2C6),
);

PauzaColorScheme get _darkColors => const PauzaColorScheme(
  primary: Color(0xFFFFB1C0),
  onPrimary: Color(0xFF650018),
  primaryContainer: Color(0xFF90002B),
  onPrimaryContainer: Color(0xFFFFD9DF),
  secondary: Color(0xFFFFB1C1),
  onSecondary: Color(0xFF5E1128),
  secondaryContainer: Color(0xFF7B263B),
  onSecondaryContainer: Color(0xFFFFD9DE),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  success: Color(0xFF81C784),
  onSuccess: Color(0xFF08310A),
  successContainer: Color(0xFF1B5E20),
  onSuccessContainer: Color(0xFFC8E6C9),
  warning: Color(0xFFFFB74D),
  onWarning: Color(0xFF3B1E00),
  warningContainer: Color(0xFF5D3A00),
  onWarningContainer: Color(0xFFFFE0B2),
  surfaceDim: Color(0xFF141012),
  surface: Color(0xFF191113),
  surfaceBright: Color(0xFF382E30),
  surfaceContainerLowest: Color(0xFF141012),
  surfaceContainerLow: Color(0xFF1F1719),
  surfaceContainer: Color(0xFF241B1E),
  surfaceContainerHigh: Color(0xFF2A2123),
  surfaceContainerHighest: Color(0xFF524346),
  onSurface: Color(0xFFEFE0E3),
  onSurfaceVariant: Color(0xFFD8C2C6),
  outline: Color(0xFFA08C90),
  outlineVariant: Color(0xFF524346),
);
ThemeData appThemeFromBrightness(Brightness brightness) {
  final colorTheme = switch (brightness) {
    Brightness.light => _lightColors,
    Brightness.dark => _darkColors,
  };

  const baseTextTheme = PauzaTextTheme.base;

  return ThemeData(
    useMaterial3: true,
    disabledColor: Color.alphaBlend(
      colorTheme.onSurface.withValues(alpha: 0.12),
      colorTheme.surface,
    ),
    primaryColor: colorTheme.primary,
    scaffoldBackgroundColor: colorTheme.surface,
    shadowColor: colorTheme.onSurface.withValues(alpha: 0.5),
    hintColor: colorTheme.outlineVariant,
    dividerColor: colorTheme.outlineVariant,
    extensions: <ThemeExtension<dynamic>>[colorTheme],
    textTheme: baseTextTheme.copyWith(
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1,
      ),
    ),
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colorTheme.primary,
      onPrimary: colorTheme.onPrimary,
      primaryContainer: colorTheme.primaryContainer,
      onPrimaryContainer: colorTheme.onPrimaryContainer,
      secondary: colorTheme.secondary,
      onSecondary: colorTheme.onSecondary,
      secondaryContainer: colorTheme.secondaryContainer,
      onSecondaryContainer: colorTheme.onSecondaryContainer,
      error: colorTheme.error,
      onError: colorTheme.onError,
      errorContainer: colorTheme.errorContainer,
      onErrorContainer: colorTheme.onErrorContainer,
      surface: colorTheme.surface,
      surfaceBright: colorTheme.surfaceBright,
      surfaceContainerLowest: colorTheme.surfaceContainerLowest,
      surfaceContainerLow: colorTheme.surfaceContainerLow,
      surfaceContainer: colorTheme.surfaceContainer,
      surfaceContainerHigh: colorTheme.surfaceContainerHigh,
      surfaceContainerHighest: colorTheme.surfaceContainerHighest,
      surfaceDim: colorTheme.surfaceDim,
      onSurface: colorTheme.onSurface,
      onSurfaceVariant: colorTheme.onSurfaceVariant,
      outline: colorTheme.outline,
      outlineVariant: colorTheme.outlineVariant,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      leadingWidth: 56,
      scrolledUnderElevation: 0,
      backgroundColor: colorTheme.surface,
      foregroundColor: colorTheme.onSurface,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorTheme.primary,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorTheme.surface,
      shadowColor: colorTheme.onSurface.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      fillColor: colorTheme.surfaceContainerLow,
      border: InputBorder.none,
    ),
    chipTheme: ChipThemeData(
      padding: EdgeInsets.zero,
      backgroundColor: colorTheme.primary,
      labelStyle: TextStyle(color: colorTheme.onPrimary),
      shape: const StadiumBorder(),
    ),
    iconTheme: IconThemeData(color: colorTheme.onSurface),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: colorTheme.primary,
        foregroundColor: colorTheme.onPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        foregroundColor: colorTheme.onSurface,
      ),
    ),
  );
}

abstract final class PauzaTheme {
  static ThemeData get light => appThemeFromBrightness(Brightness.light);

  static ThemeData get dark => appThemeFromBrightness(Brightness.dark);
}

extension PauzaThemeX on BuildContext {
  ThemeData get themeData => Theme.of(this);

  TextTheme get textTheme => TextTheme.of(this);

  ColorScheme get colorScheme => ColorScheme.of(this);

  PauzaColorScheme get pauzaColorScheme =>
      Theme.of(this).extension<PauzaColorScheme>()!;
}
