import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class AddModeButton extends StatelessWidget {
  const AddModeButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PauzaSpacing.medium,
        vertical: PauzaSpacing.medium,
      ),
      child: PauzaFilledButton(
        onPressed: onPressed,
        title: Text(l10n.addModeButton),
        icon: const Icon(Icons.add),
        width: double.infinity,
      ),
    );
  }
}
