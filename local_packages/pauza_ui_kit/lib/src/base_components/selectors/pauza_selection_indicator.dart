import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaSelectionIndicator extends StatelessWidget {
  const PauzaSelectionIndicator({required this.isSelected, super.key});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? context.colorScheme.primary : Colors.transparent,
        border: Border.all(color: isSelected ? context.colorScheme.primary : context.colorScheme.outline, width: 2),
      ),
      child: isSelected ? Icon(Icons.check, size: PauzaIconSizes.small, color: context.colorScheme.onPrimary) : null,
    );
  }
}
