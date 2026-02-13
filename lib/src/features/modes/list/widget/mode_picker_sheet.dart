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
  const ModePickerSheet({required this.modes, super.key});

  final List<Mode> modes;

  static Future<Mode?> show(BuildContext context, {required List<Mode> modes}) {
    return showModalBottomSheet<Mode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ModePickerSheet(modes: modes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(PauzaSpacing.medium),
          child: Text(
            l10n.selectModeTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (modes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(PauzaSpacing.large),
            child: Center(
              child: Text(
                l10n.noModesEmptyState,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: modes.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final mode = modes[index];
                return ModeListItem(
                  mode: mode,
                  onTap: () => _onModeTap(context, mode),
                  onEdit: () => _onEditMode(context, mode),
                  onDelete: () => _onDeleteMode(context, mode),
                );
              },
            ),
          ),
        AddModeButton(onPressed: () => _onAddNewMode(context)),
      ],
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
