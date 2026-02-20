import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaCheckbox extends StatelessWidget {
  const PauzaCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
    this.tristate = false,
    this.isError = false,
    this.size = 28,
    this.radius = PauzaCornerRadius.xxSmall,
  }) : assert(tristate || value != null);

  final bool? value;
  final bool tristate;
  final ValueChanged<bool?>? onChanged;
  final bool isError;
  final double size;
  final double radius;

  bool get _isEnabled => onChanged != null;

  void _handleTap() {
    if (!_isEnabled) {
      return;
    }
    final currentValue = value;
    final nextValue = tristate
        ? switch (currentValue) {
            false => true,
            true => null,
            null => false,
          }
        : !(currentValue ?? false);
    onChanged?.call(nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = value == true;
    final isMixed = value == null && tristate;

    final activeColor = isError ? context.colorScheme.error : context.colorScheme.primary;
    final borderColor = isError ? context.colorScheme.error : context.colorScheme.outlineVariant;

    final backgroundColor = switch ((isSelected, isMixed)) {
      (true, _) => activeColor,
      (false, true) => context.colorScheme.primaryContainer,
      _ => Colors.transparent,
    };

    final iconColor = switch ((isSelected, isMixed)) {
      (true, _) => context.colorScheme.onPrimary,
      (false, true) => context.colorScheme.onPrimaryContainer,
      _ => Colors.transparent,
    };

    return Semantics(
      checked: value == true,
      child: InkWell(
        onTap: _isEnabled ? _handleTap : null,
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: _isEnabled ? 1 : 0.55,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: isSelected || isMixed ? activeColor : borderColor, width: 2),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 120),
                child: switch ((isSelected, isMixed)) {
                  (true, _) => Icon(Icons.check, key: const ValueKey<String>('check'), size: 18, color: iconColor),
                  (false, true) => Icon(Icons.remove, key: const ValueKey<String>('dash'), size: 18, color: iconColor),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
