import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/list/widget/mode_options_menu.dart';

class ModeListItem extends StatelessWidget {
  const ModeListItem({
    required this.mode,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Mode mode;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      onTap: onTap,
      title: Text(mode.title),
      subtitle: Text(l10n.blockedAppsCountLabel(mode.blockedAppIds.length)),
      trailing: ModeOptionsMenu(onEdit: onEdit, onDelete: onDelete),
    );
  }
}
