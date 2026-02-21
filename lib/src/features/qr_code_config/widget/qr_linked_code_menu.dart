import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';

enum QrLinkedCodeMenuAction { rename, delete }

class QrLinkedCodeMenu extends StatelessWidget {
  const QrLinkedCodeMenu({
    required this.enabled,
    required this.onRenamePressed,
    required this.onDeletePressed,
    super.key,
  });

  final bool enabled;
  final VoidCallback onRenamePressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<QrLinkedCodeMenuAction>(
      enabled: enabled,
      onSelected: (action) {
        switch (action) {
          case QrLinkedCodeMenuAction.rename:
            onRenamePressed();
          case QrLinkedCodeMenuAction.delete:
            onDeletePressed();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: QrLinkedCodeMenuAction.rename, child: Text(context.l10n.qrCodeConfigRenameAction)),
        PopupMenuItem(
          value: QrLinkedCodeMenuAction.delete,
          child: Text(context.l10n.qrCodeConfigDeleteAction, style: TextStyle(color: colorScheme.error)),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
