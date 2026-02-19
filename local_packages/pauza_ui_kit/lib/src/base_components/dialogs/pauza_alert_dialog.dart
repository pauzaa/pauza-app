import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PauzaAlertDialog extends StatelessWidget {
  const PauzaAlertDialog({
    required this.title,
    required this.body,
    required this.primaryActionLabel,
    required this.onPrimaryActionPressed,
    this.secondaryActionLabel,
    this.onSecondaryActionPressed,
    super.key,
  });

  final String body;
  final String title;

  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final VoidCallback onPrimaryActionPressed;
  final VoidCallback? onSecondaryActionPressed;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String body,
    required String primaryActionLabel,
    required VoidCallback onPrimaryActionPressed,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryActionPressed,
  }) {
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PauzaAlertDialog(
        title: title,
        body: body,
        primaryActionLabel: primaryActionLabel,
        secondaryActionLabel: secondaryActionLabel,
        onPrimaryActionPressed: onPrimaryActionPressed,
        onSecondaryActionPressed: onSecondaryActionPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        if (secondaryActionLabel case final label?)
          CupertinoDialogAction(
            onPressed: onSecondaryActionPressed ?? Navigator.of(context).pop,
            textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            child: Text(label),
          ),
        CupertinoDialogAction(
          onPressed: onPrimaryActionPressed,
          isDefaultAction: true,
          textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          child: Text(primaryActionLabel),
        ),
      ],
    );
  }
}
