import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class NfcChipRenameDialog extends StatefulWidget {
  const NfcChipRenameDialog({required this.initialName, super.key});

  final String initialName;

  static Future<String?> show(BuildContext context, {required String initialName}) {
    return showDialog<String>(
      context: context,
      builder: (context) => NfcChipRenameDialog(initialName: initialName),
    );
  }

  @override
  State<NfcChipRenameDialog> createState() => _NfcChipRenameDialogState();
}

class _NfcChipRenameDialogState extends State<NfcChipRenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.initialName);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.nfcChipConfigRenameDialogTitle),
      content: PauzaTextFormField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: PauzaInputDecoration(
          labelText: context.l10n.nfcChipConfigRenameFieldLabel,
          hintText: context.l10n.nfcChipConfigRenameFieldHint,
        ),
        onFieldSubmitted: (_) => _onSavePressed(),
      ),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, child: Text(context.l10n.cancelButton)),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final canSave = _controller.text.trim().isNotEmpty;
            return FilledButton(onPressed: canSave ? _onSavePressed : null, child: Text(context.l10n.nfcChipConfigRenameSaveButton));
          },
        ),
      ],
    );
  }

  void _onSavePressed() {
    Navigator.of(context).pop(_controller.text.trim());
  }
}
