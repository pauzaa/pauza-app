import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';

class ConfirmDeleteModeDialog extends StatelessWidget {
  const ConfirmDeleteModeDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmDeleteModeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.deleteModeTitle),
      content: Text(l10n.deleteModeMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text(l10n.deleteModeButton),
        ),
      ],
    );
  }
}
