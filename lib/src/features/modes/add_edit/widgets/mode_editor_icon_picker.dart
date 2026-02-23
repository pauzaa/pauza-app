import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_icon_picker_sheet.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_upsert_draft_notifier.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorIconPicker extends StatelessWidget {
  const ModeEditorIconPicker({required this.selectedIcon, required this.enabled, super.key});

  final ModeIcon selectedIcon;
  final bool enabled;

  Future<void> _onChooseIconPressed(BuildContext context) async {
    final draftNotifier = ModeUpsertScope.watch(context);
    final l10n = context.l10n;
    final nextIcon = await ModeIconPickerSheet.show(
      context,
      title: l10n.modeIconPickerTitle,
      subtitle: l10n.modeIconPickerSubtitle,
      selectedIcon: selectedIcon,
    );
    if (!context.mounted || nextIcon == null) {
      return;
    }
    draftNotifier.updateIcon(nextIcon);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _onChooseIconPressed(context) : null,
      borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
        ),
        child: SizedBox(
          width: PauzaFormSizes.xSmall,
          height: PauzaFormSizes.xSmall,
          child: Icon(selectedIcon.icon, color: context.colorScheme.primary),
        ),
      ),
    );
  }
}
