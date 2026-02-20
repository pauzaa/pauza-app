import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorStickyActionBar extends StatelessWidget {
  const ModeEditorStickyActionBar({required this.buttonLabel, required this.onPressed, super.key, this.isBusy = false});

  final String buttonLabel;
  final VoidCallback onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(top: BorderSide(color: context.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(PauzaSpacing.medium),
        top: false,
        child: PauzaFilledButton(
          onPressed: onPressed,
          disabled: isBusy,
          width: double.infinity,
          size: PauzaButtonSize.large,
          radius: PauzaCornerRadius.large,
          title: isBusy
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: context.colorScheme.onPrimary, strokeWidth: 2.3),
                )
              : Text(buttonLabel),
        ),
      ),
    );
  }
}
