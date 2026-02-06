import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

enum PauzaButtonSize {
  xxSmall,
  xSmall,
  small,
  medium,
  large;

  double get height => switch (this) {
    PauzaButtonSize.xxSmall => PauzaFormSizes.xxSmall,
    PauzaButtonSize.xSmall => PauzaFormSizes.xSmall,
    PauzaButtonSize.small => PauzaFormSizes.small,
    PauzaButtonSize.medium => PauzaFormSizes.medium,
    PauzaButtonSize.large => PauzaFormSizes.large,
  };

  EdgeInsetsGeometry get padding => switch (this) {
    PauzaButtonSize.xxSmall => const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
    PauzaButtonSize.xSmall => const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 10,
    ),
    PauzaButtonSize.small => const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 10,
    ),
    PauzaButtonSize.medium => const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 10,
    ),
    PauzaButtonSize.large => const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 10,
    ),
  };

  double get iconGap => switch (this) {
    PauzaButtonSize.xxSmall => 8,
    PauzaButtonSize.xSmall => 8,
    PauzaButtonSize.small => 8,
    PauzaButtonSize.medium => 12,
    PauzaButtonSize.large => 16,
  };

  TextStyle textStyle(BuildContext context) => switch (this) {
    PauzaButtonSize.xxSmall =>
      context.textTheme.labelSmall ?? const TextStyle(),
    PauzaButtonSize.xSmall => context.textTheme.labelLarge ?? const TextStyle(),
    PauzaButtonSize.small => context.textTheme.labelLarge ?? const TextStyle(),
    PauzaButtonSize.medium => context.textTheme.labelLarge ?? const TextStyle(),
    PauzaButtonSize.large => context.textTheme.labelLarge ?? const TextStyle(),
  };
}

abstract base class PauzaButtonBase extends StatelessWidget {
  const PauzaButtonBase({
    required this.title,
    required this.onPressed,
    super.key,
    this.onLongPress,
    this.size = PauzaButtonSize.medium,
    this.width,
    this.elevation,
    this.radius = PauzaCornerRadius.xSmall,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.textStyle,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.disabled = false,
    this.selected = false,
    this.isLoading = false,
  });

  final Widget title;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final PauzaButtonSize size;
  final double? width;
  final double? elevation;
  final double radius;
  final Widget? icon;
  final IconAlignment iconAlignment;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool disabled;
  final bool selected;
  final bool isLoading;

  bool get isEffectivelyDisabled => disabled || isLoading || onPressed == null;

  WidgetStateProperty<Color?> backgroundColorProperty(BuildContext context);

  WidgetStateProperty<Color?> foregroundColorProperty(BuildContext context);

  WidgetStateProperty<Color?> overlayColorProperty(BuildContext context) {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed) ||
          states.contains(WidgetState.hovered)) {
        return context.colorScheme.primary.withValues(alpha: 0.12);
      }
      return Colors.transparent;
    });
  }

  BorderSide borderSideToApply(BuildContext context) => BorderSide.none;

  @override
  Widget build(BuildContext context) {
    final content = _PauzaButtonContent(
      title: title,
      icon: icon,
      iconAlignment: iconAlignment,
      iconGap: size.iconGap,
      isLoading: isLoading,
      loadingColor: foregroundColor ?? context.colorScheme.onPrimary,
    );

    final style =
        OutlinedButton.styleFrom(
          minimumSize: Size(width ?? double.minPositive, size.height),
          maximumSize: Size(width ?? double.infinity, size.height),
          elevation: elevation,
          textStyle: textStyle ?? size.textStyle(context),
          animationDuration: Duration.zero,
          side: borderSideToApply(context),
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            side: borderSideToApply(context),
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: padding ?? size.padding,
        ).copyWith(
          iconSize: const WidgetStatePropertyAll(PauzaIconSizes.small),
          iconColor: foregroundColorProperty(context),
          backgroundColor: backgroundColorProperty(context),
          overlayColor: overlayColorProperty(context),
          foregroundColor: foregroundColorProperty(context),
        );

    return OutlinedButton(
      onPressed: isEffectivelyDisabled ? null : onPressed,
      onLongPress: isEffectivelyDisabled ? null : onLongPress,
      style: style,
      child: content,
    );
  }
}

class _PauzaButtonContent extends StatelessWidget {
  const _PauzaButtonContent({
    required this.title,
    required this.icon,
    required this.iconAlignment,
    required this.iconGap,
    required this.isLoading,
    required this.loadingColor,
  });

  final Widget title;
  final Widget? icon;
  final IconAlignment iconAlignment;
  final double iconGap;
  final bool isLoading;
  final Color loadingColor;

  @override
  Widget build(BuildContext context) {
    final leading = isLoading
        ? SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            ),
          )
        : icon;

    if (leading == null) {
      return title;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconAlignment == IconAlignment.start
          ? <Widget>[leading, SizedBox(width: iconGap), Flexible(child: title)]
          : <Widget>[Flexible(child: title), SizedBox(width: iconGap), leading],
    );
  }
}
