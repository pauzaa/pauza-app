import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaFilterChip extends StatelessWidget {
  const PauzaFilterChip({
    required this.label,
    required this.onPressed,
    super.key,
    this.isSelected = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? context.colorScheme.primary
        : context.colorScheme.surfaceContainerHigh;
    final foregroundColor = isSelected
        ? context.colorScheme.onPrimary
        : context.colorScheme.onSurfaceVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PauzaSpacing.large,
            vertical: PauzaSpacing.regular,
          ),
          child: Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
