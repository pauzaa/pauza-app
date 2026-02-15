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
    PauzaButtonSize.large => context.textTheme.bodyLarge ?? const TextStyle(),
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
    this.radius = PauzaCornerRadius.medium,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.iconColor,
    this.textStyle,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.disabled = false,
    this.selected = false,
  });

  final Widget title;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final PauzaButtonSize size;
  final double? width;
  final double? elevation;
  final double radius;
  final Widget? icon;
  final IconAlignment iconAlignment;
  final Color? iconColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final bool disabled;
  final bool selected;

  WidgetStateProperty<Color?> backgroundColorProperty(BuildContext context);

  WidgetStateProperty<Color?> foregroundColorProperty(BuildContext context);

  /// Icon color uses the same state resolution as [foregroundColorProperty].
  /// When [iconColor] is null, defaults to [foregroundColorProperty].
  WidgetStateProperty<Color?> iconColorProperty(BuildContext context);

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
          iconSize: PauzaIconSizes.small,
        ).copyWith(
          iconColor: iconColorProperty(context),
          backgroundColor: backgroundColorProperty(context),
          overlayColor: overlayColorProperty(context),
          foregroundColor: foregroundColorProperty(context),
        );

    return OutlinedButton(
      onPressed: disabled ? null : onPressed,
      onLongPress: disabled ? null : onLongPress,
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
  });

  final Widget title;
  final Widget? icon;
  final IconAlignment iconAlignment;
  final double iconGap;

  @override
  Widget build(BuildContext context) {
    final leading = icon;

    if (leading == null) {
      return title;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: iconGap,
      children: iconAlignment == IconAlignment.start
          ? <Widget>[leading, Flexible(child: title)]
          : <Widget>[Flexible(child: title), leading],
    );
  }
}
