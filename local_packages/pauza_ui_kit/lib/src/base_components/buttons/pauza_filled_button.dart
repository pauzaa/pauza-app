import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/base_components/buttons/pauza_button_base.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaFilledButton extends PauzaButtonBase {
  const PauzaFilledButton({
    required super.title,
    required super.onPressed,
    super.key,
    super.onLongPress,
    super.size,
    super.width,
    super.elevation,
    super.radius,
    super.icon,
    super.iconAlignment,
    super.textStyle,
    super.padding,
    super.backgroundColor,
    super.foregroundColor,
    super.disabled,
    super.selected,
    super.isLoading,
  });

  @override
  WidgetStateProperty<Color?> backgroundColorProperty(BuildContext context) {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return context.themeData.disabledColor;
      }
      return backgroundColor ?? context.colorScheme.primary;
    });
  }

  @override
  WidgetStateProperty<Color?> foregroundColorProperty(BuildContext context) {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return context.colorScheme.onSurface.withValues(alpha: 0.38);
      }
      return foregroundColor ?? context.colorScheme.onPrimary;
    });
  }
}
