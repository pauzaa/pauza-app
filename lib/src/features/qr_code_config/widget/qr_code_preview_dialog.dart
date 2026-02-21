import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePreviewDialog extends StatelessWidget {
  const QrCodePreviewDialog({required this.code, super.key});

  final QrLinkedCode code;

  static Future<void> show(BuildContext context, {required QrLinkedCode code}) {
    return showDialog<void>(
      context: context,
      builder: (context) => QrCodePreviewDialog(code: code),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(context.l10n.qrCodeConfigPreviewDialogTitle),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              context.l10n.qrCodeConfigPreviewDialogBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            Text(code.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(child: QrImageView(data: code.scanValue.normalized, size: 200)),
              ),
            ),
            SelectableText(
              code.scanValue.normalized,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: Navigator.of(context).pop, child: Text(context.l10n.closeButton))],
    );
  }
}
