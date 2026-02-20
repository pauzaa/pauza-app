import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorCard extends StatelessWidget {
  const ModeEditorCard({
    required this.child,
    super.key,
    this.padding,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        border: Border.all(
          color: borderColor ?? context.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
