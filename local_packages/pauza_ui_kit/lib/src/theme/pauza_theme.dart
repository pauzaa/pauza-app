import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

PauzaColorScheme get _lightColors => const PauzaColorScheme(
  primary: Color(0xFF800020),
  onPrimary: Colors.white,
  primaryContainer: Colors.white,
  onPrimaryContainer: Color(0xFF800020),
  secondary: Color(0xFF800020),
  onSecondary: Colors.white,
  secondaryContainer: Colors.white,
  onSecondaryContainer: Color(0xFF800020),
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
  surfaceDim: Color(0xFFF6F4F5),
  surface: Colors.white,
  surfaceBright: Colors.white,
  surfaceContainerLowest: Colors.white,
  surfaceContainerLow: Color(0xFFFCFAFB),
  surfaceContainer: Color(0xFFF8F5F6),
  surfaceContainerHigh: Color(0xFFF3EFF0),
  surfaceContainerHighest: Color(0xFFEEE8EA),
  onSurface: Color(0xFF171214),
  onSurfaceVariant: Color(0xFF6D6470),
  outline: Color(0xFFB0A8B2),
  outlineVariant: Color(0xFFD9D3D8),
);

PauzaColorScheme get _darkColors => const PauzaColorScheme(
  primary: Color(0xFF800020),
  onPrimary: Colors.white,
  primaryContainer: Colors.black,
  onPrimaryContainer: Colors.white,
  secondary: Color(0xFF800020),
  onSecondary: Colors.white,
  secondaryContainer: Colors.black,
  onSecondaryContainer: Colors.white,
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
  surfaceDim: Color(0xFF050405),
  surface: Color(0xFF070607),
  surfaceBright: Color(0xFF1A1718),
  surfaceContainerLowest: Color(0xFF040304),
  surfaceContainerLow: Color(0xFF0B090A),
  surfaceContainer: Color(0xFF100D0E),
  surfaceContainerHigh: Color(0xFF151112),
  surfaceContainerHighest: Color(0xFF1C1719),
  onSurface: Color(0xFFF4F2F3),
  onSurfaceVariant: Color(0xFF97A2B6),
  outline: Color(0xFF2A2D33),
  outlineVariant: Color(0xFF202329),
);
ThemeData appThemeFromBrightness(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorTheme = switch (brightness) {
    Brightness.light => _lightColors,
    Brightness.dark => _darkColors,
  };

  final pauzaTextTheme = PauzaTextTheme.fromColorTheme(colorTheme);

  return ThemeData(
    useMaterial3: true,
    disabledColor: Color.alphaBlend(
      colorTheme.onSurface.withValues(alpha: isDark ? 0.16 : 0.12),
      colorTheme.surface,
    ),
    primaryColor: colorTheme.primary,
    scaffoldBackgroundColor: colorTheme.surface,
    shadowColor: colorTheme.onSurface.withValues(alpha: isDark ? 0.7 : 0.5),
    hintColor: colorTheme.outlineVariant,
    dividerColor: colorTheme.outlineVariant,
    fontFamily: PauzaTextTheme.fontFamily,
    extensions: <ThemeExtension<dynamic>>[colorTheme, pauzaTextTheme],
    textTheme: pauzaTextTheme.material,
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
      centerTitle: true,
      foregroundColor: colorTheme.onSurface,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorTheme.primary,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorTheme.surfaceContainerLow,
      shadowColor: colorTheme.onSurface.withValues(alpha: isDark ? 0.8 : 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorTheme.outline.withValues(alpha: isDark ? 0.9 : 0.6),
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      showDragHandle: true,
      backgroundColor: colorTheme.surface,
      modalElevation: 2,
      modalBackgroundColor: colorTheme.surface,
      shadowColor: colorTheme.onSurface.withValues(alpha: isDark ? 0.7 : 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(PauzaCornerRadius.large),
        ),
        side: BorderSide(
          color: colorTheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      suffixIconColor: colorTheme.onSurfaceVariant,
      prefixIconColor: colorTheme.onSurfaceVariant,
      labelStyle: pauzaTextTheme.bodyLarge.copyWith(
        color: colorTheme.onSurface,
      ),
      errorStyle: pauzaTextTheme.bodySmall.copyWith(color: colorTheme.error),
      helperStyle: pauzaTextTheme.bodySmall.copyWith(
        color: colorTheme.onSurfaceVariant,
      ),
      prefixStyle: pauzaTextTheme.bodyLarge.copyWith(
        color: colorTheme.onSurfaceVariant,
      ),
      suffixStyle: pauzaTextTheme.bodyLarge.copyWith(
        color: colorTheme.onSurfaceVariant,
      ),
      hintStyle: pauzaTextTheme.bodyLarge.copyWith(
        color: colorTheme.outlineVariant,
      ),

      hoverColor: colorTheme.primary,
      focusColor: colorTheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: isDark
          ? colorTheme.surfaceContainer
          : colorTheme.surfaceContainerLow,
      border: InputBorder.none,
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.xxSmall),
        borderSide: BorderSide(width: 2, color: colorTheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.xxSmall),
        borderSide: BorderSide(width: 2, color: colorTheme.error),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.xxSmall),
        borderSide: BorderSide(width: 2, color: colorTheme.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.xxSmall),
        borderSide: BorderSide(color: colorTheme.outline),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.xxSmall),
        borderSide: BorderSide(
          color: colorTheme.onSurfaceVariant.withAlpha(40),
        ),
      ),
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
        foregroundColor: colorTheme.onSurfaceVariant,
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

  PauzaTextTheme get pauzaTextTheme =>
      Theme.of(this).extension<PauzaTextTheme>()!;

  ColorScheme get colorScheme => ColorScheme.of(this);

  PauzaColorScheme get pauzaColorScheme =>
      Theme.of(this).extension<PauzaColorScheme>()!;
}
