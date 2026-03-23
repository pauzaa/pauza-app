import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';

class ConfirmEmergencyStopDialog extends StatelessWidget {
  const ConfirmEmergencyStopDialog({required this.remainingStops, super.key});

  final int remainingStops;

  static Future<bool?> show(BuildContext context, {required int remainingStops}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmEmergencyStopDialog(remainingStops: remainingStops),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.emergencyStopDialogTitle),
      content: Text(l10n.emergencyStopDialogBody(remainingStops)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text(l10n.emergencyStopDialogConfirm),
        ),
      ],
    );
  }
}
