import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class QrCodeRenameDialog extends StatefulWidget {
  const QrCodeRenameDialog({required this.initialName, super.key});

  final String initialName;

  static Future<String?> show(BuildContext context, {required String initialName}) {
    return showDialog<String>(
      context: context,
      builder: (context) => QrCodeRenameDialog(initialName: initialName),
    );
  }

  @override
  State<QrCodeRenameDialog> createState() => _QrCodeRenameDialogState();
}

class _QrCodeRenameDialogState extends State<QrCodeRenameDialog> {
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
      title: Text(context.l10n.qrCodeConfigRenameDialogTitle),
      content: PauzaTextFormField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: PauzaInputDecoration(
          labelText: context.l10n.qrCodeConfigRenameFieldLabel,
          hintText: context.l10n.qrCodeConfigRenameFieldHint,
        ),
        onFieldSubmitted: (_) => _onSavePressed(),
      ),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, child: Text(context.l10n.cancelButton)),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final canSave = _controller.text.trim().isNotEmpty;
            return FilledButton(
              onPressed: canSave ? _onSavePressed : null,
              child: Text(context.l10n.qrCodeConfigRenameSaveButton),
            );
          },
        ),
      ],
    );
  }

  void _onSavePressed() {
    Navigator.of(context).pop(_controller.text.trim());
  }
}
