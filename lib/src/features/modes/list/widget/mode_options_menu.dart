import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';

class ModeOptionsMenu extends StatelessWidget {
  const ModeOptionsMenu({required this.onEdit, required this.onDelete, super.key});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopupMenuButton<void>(
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: onEdit,
          child: Row(children: [const Icon(Icons.edit), const SizedBox(width: 8), Text(l10n.editModeButton)]),
        ),
        PopupMenuItem(
          onTap: onDelete,
          child: Row(
            children: [
              Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Text(l10n.deleteModeButton, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}
