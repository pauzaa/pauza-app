import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';

enum _NfcLinkedChipMenuAction { rename, delete }

class NfcLinkedChipMenu extends StatelessWidget {
  const NfcLinkedChipMenu({required this.enabled, required this.onRenamePressed, required this.onDeletePressed, super.key});

  final bool enabled;
  final VoidCallback onRenamePressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<_NfcLinkedChipMenuAction>(
      enabled: enabled,
      onSelected: (action) {
        switch (action) {
          case _NfcLinkedChipMenuAction.rename:
            onRenamePressed();
          case _NfcLinkedChipMenuAction.delete:
            onDeletePressed();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: _NfcLinkedChipMenuAction.rename, child: Text(context.l10n.nfcChipConfigRenameAction)),
        PopupMenuItem(
          value: _NfcLinkedChipMenuAction.delete,
          child: Text(context.l10n.nfcChipConfigDeleteAction, style: TextStyle(color: colorScheme.error)),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
