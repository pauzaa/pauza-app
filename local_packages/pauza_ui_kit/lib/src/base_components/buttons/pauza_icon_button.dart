import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

enum PauzaIconButtonType { standard, filled, outlined, tonal }

final class PauzaIconButton extends StatelessWidget {
  const PauzaIconButton({
    required this.onPressed,
    required this.icon,
    super.key,
    this.onLongPressed,
    this.isSelected,
    this.selectedIcon,
    this.focusNode,
    this.disabled = false,
    this.focused = false,
    this.shape,
    this.foregroundColor,
    this.backgroundColor,
    this.focusedForegroundColor,
    this.focusedBackgroundColor,
    this.buttonSize,
  }) : type = PauzaIconButtonType.standard;

  const PauzaIconButton.filled({
    required this.onPressed,
    required this.icon,
    super.key,
    this.onLongPressed,
    this.isSelected,
    this.selectedIcon,
    this.focusNode,
    this.disabled = false,
    this.focused = false,
    this.shape,
    this.foregroundColor,
    this.backgroundColor,
    this.focusedForegroundColor,
    this.focusedBackgroundColor,
    this.buttonSize,
  }) : type = PauzaIconButtonType.filled;

  const PauzaIconButton.outlined({
    required this.onPressed,
    required this.icon,
    super.key,
    this.onLongPressed,
    this.isSelected,
    this.selectedIcon,
    this.focusNode,
    this.disabled = false,
    this.focused = false,
    this.shape,
    this.foregroundColor,
    this.backgroundColor,
    this.focusedForegroundColor,
    this.focusedBackgroundColor,
    this.buttonSize,
  }) : type = PauzaIconButtonType.outlined;

  const PauzaIconButton.tonal({
    required this.onPressed,
    required this.icon,
    super.key,
    this.onLongPressed,
    this.isSelected,
    this.selectedIcon,
    this.focusNode,
    this.disabled = false,
    this.focused = false,
    this.shape,
    this.foregroundColor,
    this.backgroundColor,
    this.focusedForegroundColor,
    this.focusedBackgroundColor,
    this.buttonSize,
  }) : type = PauzaIconButtonType.tonal;

  final Widget icon;
  final FocusNode? focusNode;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final bool disabled;
  final bool? isSelected;
  final Widget? selectedIcon;
  final bool focused;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? focusedForegroundColor;
  final Color? focusedBackgroundColor;
  final OutlinedBorder? shape;
  final Size? buttonSize;
  final PauzaIconButtonType type;

  Color _foregroundColorToApply(BuildContext context) {
    if (foregroundColor case final color?) {
      return color;
    }
    return switch (type) {
      PauzaIconButtonType.filled => context.colorScheme.onPrimary,
      PauzaIconButtonType.tonal => context.colorScheme.onSecondaryContainer,
      PauzaIconButtonType.standard ||
      PauzaIconButtonType.outlined => context.colorScheme.onSurfaceVariant,
    };
  }

  Color _backgroundColorToApply(BuildContext context) {
    if (backgroundColor case final color?) {
      return color;
    }
    return switch (type) {
      PauzaIconButtonType.filled => context.colorScheme.primary,
      PauzaIconButtonType.tonal => context.colorScheme.secondaryContainer,
      PauzaIconButtonType.standard ||
      PauzaIconButtonType.outlined => Colors.transparent,
    };
  }

  Color _focusedForegroundColorToApply(BuildContext context) {
    if (focusedForegroundColor case final color?) {
      return color;
    }
    return _foregroundColorToApply(context);
  }

  Color _focusedBackgroundColorToApply(BuildContext context) {
    if (focusedBackgroundColor case final color?) {
      return color;
    }
    return switch (type) {
      PauzaIconButtonType.outlined =>
        context.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
      PauzaIconButtonType.tonal =>
        context.colorScheme.secondaryContainer.withValues(alpha: 0.2),
      PauzaIconButtonType.standard => context.colorScheme.onSurface.withValues(
        alpha: 0.2,
      ),
      PauzaIconButtonType.filled => context.colorScheme.onSurface.withValues(
        alpha: 0.12,
      ),
    };
  }

  WidgetStateProperty<Color?> _backgroundColorProperty(BuildContext context) {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (focused) {
        return _focusedBackgroundColorToApply(context);
      }
      if (states.contains(WidgetState.disabled) &&
          (type == PauzaIconButtonType.filled ||
              type == PauzaIconButtonType.tonal)) {
        return context.themeData.disabledColor;
      }
      return _backgroundColorToApply(context);
    });
  }

  WidgetStateProperty<Color?> _foregroundColorProperty(BuildContext context) {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (focused ||
          states.contains(WidgetState.pressed) ||
          states.contains(WidgetState.hovered)) {
        return _focusedForegroundColorToApply(context);
      }
      if (states.contains(WidgetState.disabled)) {
        return context.colorScheme.onSurface.withValues(alpha: 0.3);
      }
      return _foregroundColorToApply(context);
    });
  }

  WidgetStateProperty<Color?> _overlayColorProperty(BuildContext context) {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (focused ||
          states.contains(WidgetState.pressed) ||
          states.contains(WidgetState.hovered)) {
        return _focusedBackgroundColorToApply(context);
      }
      return Colors.transparent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PauzaFormSizes.xSmall,
      height: PauzaFormSizes.xSmall,
      child: Center(
        child: IconButton(
          onPressed: disabled ? null : onPressed,
          onLongPress: disabled ? null : onLongPressed,
          focusNode: focusNode,
          isSelected: isSelected,
          selectedIcon: selectedIcon,
          icon: icon,
          iconSize: PauzaIconSizes.small,
          style:
              OutlinedButton.styleFrom(
                fixedSize:
                    buttonSize ??
                    const Size(PauzaFormSizes.xxSmall, PauzaFormSizes.xxSmall),
                shape:
                    shape ??
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        PauzaCornerRadius.full,
                      ),
                    ),
                side: type == PauzaIconButtonType.outlined
                    ? BorderSide(color: context.colorScheme.outlineVariant)
                    : BorderSide.none,
                splashFactory: NoSplash.splashFactory,
              ).copyWith(
                backgroundColor: _backgroundColorProperty(context),
                overlayColor: _overlayColorProperty(context),
                foregroundColor: _foregroundColorProperty(context),
              ),
        ),
      ),
    );
  }
}
