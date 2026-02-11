import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_screen.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza/src/features/modes/list/widget/confirm_delete_mode_dialog.dart';

class ModePickerSheet extends StatelessWidget {
  const ModePickerSheet({required this.modes, super.key});

  final List<Mode> modes;

  static Future<Mode?> show(BuildContext context, {required List<Mode> modes}) {
    return showModalBottomSheet<Mode>(
      context: context,
      builder: (context) => ModePickerSheet(modes: modes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void onModeTap(BuildContext context, Mode mode) {
    Navigator.of(context).pop(mode);
  }

  void onEditMode(BuildContext context, Mode mode) {
    ModeEditorScreen.show(context, modeId: mode.id);
  }

  Future<void> onDeleteMode(BuildContext context, Mode mode) async {
    final delete = await ConfirmDeleteModeDialog.show(context);

    if (delete == true && context.mounted) {
      context.read<ModesListBloc>().add(ModesDeleteRequested(modeId: mode.id));
    }
  }

  void onAddNewMode(BuildContext context) {
    ModeEditorScreen.show(context);
  }
}
