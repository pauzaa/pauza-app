import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_screen.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza/src/features/modes/list/widget/add_mode_button.dart';
import 'package:pauza/src/features/modes/list/widget/confirm_delete_mode_dialog.dart';
import 'package:pauza/src/features/modes/list/widget/mode_list_item.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ModePickerSheet extends StatelessWidget {
  const ModePickerSheet({required this.modes, this.activeModeId, super.key});

  final List<Mode> modes;
  final String? activeModeId;

  static Future<Mode?> show(
    BuildContext context, {
    required List<Mode> modes,
    String? activeModeId,
  }) {
    return showModalBottomSheet<Mode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ModePickerSheet(modes: modes, activeModeId: activeModeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(PauzaCornerRadius.large),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: PauzaSpacing.regular),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
                ),
                child: const SizedBox(width: 54, height: 5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PauzaSpacing.medium,
                PauzaSpacing.medium,
                PauzaSpacing.small,
                PauzaSpacing.medium,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      l10n.selectModeTitle,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            if (modes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(PauzaSpacing.large),
                child: Center(
                  child: Text(
                    l10n.noModesEmptyState,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PauzaSpacing.medium,
                  ),
                  itemCount: modes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: PauzaSpacing.regular),
                  itemBuilder: (context, index) {
                    final mode = modes[index];
                    return ModeListItem(
                      mode: mode,
                      isSelected: mode.id == activeModeId,
                      onTap: () => _onModeTap(context, mode),
                      onEdit: () => _onEditMode(context, mode),
                      onDelete: () => _onDeleteMode(context, mode),
                    );
                  },
                ),
              ),
            AddModeButton(onPressed: () => _onAddNewMode(context)),
            const SizedBox(height: PauzaSpacing.large),
          ],
        ),
      ),
    );
  }

  void _onModeTap(BuildContext context, Mode mode) {
    Navigator.of(context).pop(mode);
  }

  void _onEditMode(BuildContext context, Mode mode) {
    ModeEditorScreen.show(context, modeId: mode.id);
  }

  Future<void> _onDeleteMode(BuildContext context, Mode mode) async {
    final delete = await ConfirmDeleteModeDialog.show(context);

    if (delete == true && context.mounted) {
      context.read<ModesListBloc>().add(ModesDeleteRequested(modeId: mode.id));
    }
  }

  void _onAddNewMode(BuildContext context) {
    ModeEditorScreen.show(context);
  }
}
