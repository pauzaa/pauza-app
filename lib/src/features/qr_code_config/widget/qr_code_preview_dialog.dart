import 'package:flutter/material.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_code_sharer.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePreviewDialog extends StatefulWidget {
  const QrCodePreviewDialog({required this.code, super.key});

  final QrLinkedCode code;

  static Future<void> show(BuildContext context, {required QrLinkedCode code}) {
    return showDialog<void>(
      context: context,
      builder: (context) => QrCodePreviewDialog(code: code),
    );
  }

  @override
  State<QrCodePreviewDialog> createState() => _QrCodePreviewDialogState();
}

class _QrCodePreviewDialogState extends State<QrCodePreviewDialog> with QrCodeSharer {
  Future<void> _onDownloadPressed() async {
    try {
      final shared = await shareQrCode(
        scanValue: widget.code.scanValue.normalized,
        codeName: widget.code.name,
        codeId: widget.code.id,
      );
      if (!shared || !mounted) return;
      context.showToast(context.l10n.qrCodeConfigPreviewDialogDownloadReady);
    } catch (_) {
      if (!mounted) return;
      context.showToast(context.l10n.qrCodeConfigPreviewDialogDownloadFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(context.l10n.qrCodeConfigPreviewDialogTitle)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: Navigator.of(context).pop,
            tooltip: context.l10n.closeButton,
          ),
        ],
      ),
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
            Text(
              widget.code.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: QrImageView(
                    data: widget.code.scanValue.normalized,
                    size: 200,
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            PauzaOutlinedButton(
              onPressed: _onDownloadPressed,
              disabled: isSharing,
              size: PauzaButtonSize.small,
              width: double.infinity,
              icon: const Icon(Icons.download_rounded),
              title: Text(context.l10n.qrCodeConfigPreviewDialogDownloadButton),
            ),
            SelectableText(
              widget.code.scanValue.normalized,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
