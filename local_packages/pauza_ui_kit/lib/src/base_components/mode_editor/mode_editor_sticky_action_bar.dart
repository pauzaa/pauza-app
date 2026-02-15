import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/base_components/buttons/pauza_button_base.dart';
import 'package:pauza_ui_kit/src/base_components/buttons/pauza_filled_button.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class ModeEditorStickyActionBar extends StatelessWidget {
  const ModeEditorStickyActionBar({
    required this.buttonLabel,
    required this.onPressed,
    super.key,
    this.isBusy = false,
  });

  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          top: BorderSide(color: context.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(PauzaSpacing.medium),
        top: false,
        child: PauzaFilledButton(
          onPressed: isBusy ? () {} : (onPressed ?? () {}),
          disabled: isBusy || onPressed == null,
          width: double.infinity,
          size: PauzaButtonSize.large,
          radius: PauzaCornerRadius.large,
          title: isBusy
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: context.colorScheme.onPrimary,
                    strokeWidth: 2.3,
                  ),
                )
              : Text(
                  buttonLabel,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
