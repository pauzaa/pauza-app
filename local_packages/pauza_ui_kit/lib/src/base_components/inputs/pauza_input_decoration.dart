import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

enum PauzaTextFieldIconVisibility { onFocus, always }

class PauzaInputDecoration {
  const PauzaInputDecoration({
    this.icon,
    this.iconColor,
    this.label,
    this.labelText,
    this.labelStyle,
    this.helper,
    this.helperText = '',
    this.helperStyle,
    this.hintText,
    this.hintStyle,
    this.error,
    this.errorText,
    this.errorStyle,
    this.contentPadding,
    this.prefixIcon,
    this.prefix,
    this.prefixText,
    this.prefixStyle,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffix,
    this.suffixText,
    this.suffixStyle,
    this.suffixIconColor,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.errorBorder,
    this.focusedBorder,
    this.focusedErrorBorder,
    this.disabledBorder,
    this.enabledBorder,
    this.border,
    this.enabled = true,
    this.filled,
    this.prefixIconVisibility = PauzaTextFieldIconVisibility.always,
    this.suffixIconVisibility = PauzaTextFieldIconVisibility.always,
    this.automaticallyImplyClear = false,
    this.disabledColor,
  }) : assert(
         !(label != null && labelText != null),
         'Declaring both label and labelText is not supported.',
       );

  final Widget? icon;
  final Color? iconColor;
  final Widget? label;
  final String? labelText;
  final TextStyle? labelStyle;
  final Widget? helper;
  final String? helperText;
  final TextStyle? helperStyle;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? error;
  final String? errorText;
  final TextStyle? errorStyle;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final Widget? prefix;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final Color? prefixIconColor;
  final Widget? suffixIcon;
  final Widget? suffix;
  final String? suffixText;
  final TextStyle? suffixStyle;
  final Color? suffixIconColor;
  final Color? fillColor;
  final Color? focusColor;
  final Color? hoverColor;
  final InputBorder? errorBorder;
  final InputBorder? focusedBorder;
  final InputBorder? focusedErrorBorder;
  final InputBorder? disabledBorder;
  final InputBorder? enabledBorder;
  final InputBorder? border;
  final bool enabled;
  final bool? filled;
  final PauzaTextFieldIconVisibility prefixIconVisibility;
  final PauzaTextFieldIconVisibility suffixIconVisibility;
  final bool automaticallyImplyClear;
  final Color? disabledColor;

  PauzaInputDecoration applyDefaults(InputDecorationThemeData theme) {
    return copyWith(
      helperStyle: helperStyle ?? theme.helperStyle,
      hintStyle: hintStyle ?? theme.hintStyle,
      errorStyle: errorStyle ?? theme.errorStyle,
      contentPadding: contentPadding ?? theme.contentPadding,
      prefixStyle: prefixStyle ?? theme.prefixStyle,
      suffixStyle: suffixStyle ?? theme.suffixStyle,
      filled: filled ?? theme.filled,
      fillColor: fillColor ?? theme.fillColor,
      focusColor: focusColor ?? theme.focusColor,
      hoverColor: hoverColor ?? theme.hoverColor,
      errorBorder: errorBorder ?? theme.errorBorder,
      focusedBorder: focusedBorder ?? theme.focusedBorder,
      focusedErrorBorder: focusedErrorBorder ?? theme.focusedErrorBorder,
      disabledBorder: disabledBorder ?? theme.disabledBorder,
      enabledBorder: enabledBorder ?? theme.enabledBorder,
      border: border ?? theme.border,
    );
  }

  PauzaInputDecoration copyWith({
    Widget? icon,
    Color? iconColor,
    Widget? label,
    String? labelText,
    TextStyle? labelStyle,
    Widget? helper,
    String? helperText,
    TextStyle? helperStyle,
    String? hintText,
    TextStyle? hintStyle,
    Widget? error,
    String? errorText,
    TextStyle? errorStyle,
    EdgeInsetsGeometry? contentPadding,
    Widget? prefixIcon,
    Widget? prefix,
    String? prefixText,
    TextStyle? prefixStyle,
    Color? prefixIconColor,
    Widget? suffixIcon,
    Widget? suffix,
    String? suffixText,
    TextStyle? suffixStyle,
    Color? suffixIconColor,
    Color? fillColor,
    Color? focusColor,
    Color? hoverColor,
    InputBorder? errorBorder,
    InputBorder? focusedBorder,
    InputBorder? focusedErrorBorder,
    InputBorder? disabledBorder,
    InputBorder? enabledBorder,
    InputBorder? border,
    bool? enabled,
    bool? filled,
    PauzaTextFieldIconVisibility? prefixIconVisibility,
    PauzaTextFieldIconVisibility? suffixIconVisibility,
    bool? automaticallyImplyClear,
    Color? disabledColor,
  }) {
    return PauzaInputDecoration(
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      label: label ?? this.label,
      labelText: labelText ?? this.labelText,
      labelStyle: labelStyle ?? this.labelStyle,
      helper: helper ?? this.helper,
      helperText: helperText ?? this.helperText,
      helperStyle: helperStyle ?? this.helperStyle,
      hintText: hintText ?? this.hintText,
      hintStyle: hintStyle ?? this.hintStyle,
      error: error ?? this.error,
      errorText: errorText ?? this.errorText,
      errorStyle: errorStyle ?? this.errorStyle,
      contentPadding: contentPadding ?? this.contentPadding,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      prefix: prefix ?? this.prefix,
      prefixText: prefixText ?? this.prefixText,
      prefixStyle: prefixStyle ?? this.prefixStyle,
      prefixIconColor: prefixIconColor ?? this.prefixIconColor,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      suffix: suffix ?? this.suffix,
      suffixText: suffixText ?? this.suffixText,
      suffixStyle: suffixStyle ?? this.suffixStyle,
      suffixIconColor: suffixIconColor ?? this.suffixIconColor,
      fillColor: fillColor ?? this.fillColor,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      errorBorder: errorBorder ?? this.errorBorder,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      focusedErrorBorder: focusedErrorBorder ?? this.focusedErrorBorder,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      enabledBorder: enabledBorder ?? this.enabledBorder,
      border: border ?? this.border,
      enabled: enabled ?? this.enabled,
      filled: filled ?? this.filled,
      prefixIconVisibility: prefixIconVisibility ?? this.prefixIconVisibility,
      suffixIconVisibility: suffixIconVisibility ?? this.suffixIconVisibility,
      automaticallyImplyClear:
          automaticallyImplyClear ?? this.automaticallyImplyClear,
      disabledColor: disabledColor ?? this.disabledColor,
    );
  }

  InputDecoration configureInputDecoration(
    BuildContext context, {
    required bool hasFocus,
    required bool isEnabled,
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    final theme = Theme.of(context).inputDecorationTheme;

    final effectivePrefixIconColor = isEnabled
        ? (prefixIconColor ?? theme.prefixIconColor)
        : (prefixIconColor ?? theme.prefixIconColor)?.withValues(alpha: 0.55);
    final effectiveSuffixIconColor = isEnabled
        ? (suffixIconColor ?? theme.suffixIconColor)
        : (suffixIconColor ?? theme.suffixIconColor)?.withValues(alpha: 0.55);

    Widget? effectivePrefixIcon;
    switch ((prefixIconVisibility, hasFocus)) {
      case (PauzaTextFieldIconVisibility.always, _):
      case (PauzaTextFieldIconVisibility.onFocus, true):
        effectivePrefixIcon = prefixIcon;
      case (PauzaTextFieldIconVisibility.onFocus, false):
        effectivePrefixIcon = null;
    }

    Widget? effectiveSuffixIcon;
    switch ((suffixIconVisibility, hasFocus)) {
      case (PauzaTextFieldIconVisibility.always, _):
      case (PauzaTextFieldIconVisibility.onFocus, true):
        if (suffixIcon case final icon?) {
          effectiveSuffixIcon = IconTheme(
            data: IconThemeData(
              color: effectiveSuffixIconColor,
              size: PauzaIconSizes.small,
            ),
            child: icon,
          );
        } else if (automaticallyImplyClear && controller.text.isNotEmpty) {
          effectiveSuffixIcon = IconButton(
            onPressed: () {
              controller.clear();
              onChanged?.call('');
            },
            icon: const Icon(Icons.cancel_outlined),
            iconSize: PauzaIconSizes.small,
            color: effectiveSuffixIconColor,
            splashRadius: 18,
          );
        }
      case (PauzaTextFieldIconVisibility.onFocus, false):
        effectiveSuffixIcon = null;
    }

    return InputDecoration(
      icon: icon,
      iconColor: iconColor ?? theme.iconColor,
      helper: helper,
      helperText: helperText,
      helperStyle: helperStyle ?? theme.helperStyle,
      hintText: hintText,
      hintStyle: hintStyle ?? theme.hintStyle,
      error: error,
      errorText: this.errorText ?? errorText,
      errorStyle: errorStyle ?? theme.errorStyle,
      contentPadding: contentPadding ?? theme.contentPadding,
      prefixIcon: effectivePrefixIcon,
      prefix: prefix,
      prefixText: prefixText,
      prefixStyle: prefixStyle ?? theme.prefixStyle,
      prefixIconColor: effectivePrefixIconColor,
      suffixIcon: effectiveSuffixIcon,
      suffix: suffix,
      suffixText: suffixText,
      suffixStyle: suffixStyle ?? theme.suffixStyle,
      suffixIconColor: effectiveSuffixIconColor,
      filled: filled ?? theme.filled,
      fillColor: isEnabled
          ? (fillColor ?? theme.fillColor)
          : ((disabledColor ?? context.colorScheme.surfaceContainerLow)
                .withValues(alpha: 0.6)),
      focusColor: focusColor ?? theme.focusColor,
      hoverColor: hoverColor ?? theme.hoverColor,
      errorBorder: errorBorder ?? theme.errorBorder,
      focusedBorder: focusedBorder ?? theme.focusedBorder,
      focusedErrorBorder: focusedErrorBorder ?? theme.focusedErrorBorder,
      disabledBorder: disabledBorder ?? theme.disabledBorder,
      enabledBorder: enabledBorder ?? theme.enabledBorder,
      border: border ?? theme.border,
    );
  }
}
