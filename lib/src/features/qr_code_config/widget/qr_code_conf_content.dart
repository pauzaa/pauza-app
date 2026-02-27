import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/qr_code_config/bloc/qr_code_conf_bloc.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_code_preview_dialog.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_code_rename_dialog.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_linked_code_list.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class QrCodeConfContent extends StatelessWidget {
  const QrCodeConfContent({
    super.key,
    this.renameDialogOpener = QrCodeRenameDialog.show,
    this.previewDialogOpener = QrCodePreviewDialog.show,
  });

  final Future<String?> Function(BuildContext context, {required String initialName}) renameDialogOpener;
  final Future<void> Function(BuildContext context, {required QrLinkedCode code}) previewDialogOpener;

  @override
  Widget build(BuildContext context) {
    return BlocListener<QrCodeConfBloc, QrCodeConfState>(
      listenWhen: (previous, current) => previous != current && current.isError,
      listener: (context, state) {
        switch (state) {
          case QrCodeConfIdle():
          case QrCodeConfLoading():
            break;
          case QrCodeConfError():
            final message = switch (state.error) {
              final Localizable localizable => localizable.localize(context.l10n),
              _ => context.l10n.qrCodeConfigActionFailed,
            };
            context.showToast(message);
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.qrCodeConfigTagsTitle)),
        body: BlocBuilder<QrCodeConfBloc, QrCodeConfState>(
          builder: (context, state) {
            return Stack(
              children: [
                AbsorbPointer(
                  absorbing: state.isLoading,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.large),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: PauzaSpacing.large,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.qrCodeConfigTagsBody,
                          style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
                        ),
                        Expanded(
                          child: QrLinkedCodeList(
                            linkedCodes: state.linkedCodes,
                            isLoading: state.isLoading,
                            onRenamePressed: (code) => _onRenamePressed(context, code),
                            onDeletePressed: (code) => _onDeletePressed(context, code),
                            onPreviewPressed: (code) => _onPreviewPressed(context, code),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.isLoading)
                  const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator(minHeight: 2)),
              ],
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            PauzaSpacing.large,
            PauzaSpacing.regular,
            PauzaSpacing.large,
            PauzaSpacing.medium,
          ),
          top: false,
          child: BlocSelector<QrCodeConfBloc, QrCodeConfState, bool>(
            selector: (state) => state.isLoading,
            builder: (context, isLoading) {
              return PauzaFilledButton(
                onPressed: () => _onGeneratePressed(context),
                disabled: isLoading,
                size: PauzaButtonSize.large,
                icon: const Icon(Icons.add_circle),
                textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                title: Text(context.l10n.qrCodeConfigGenerateNewCodeButton),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onGeneratePressed(BuildContext context) {
    context.read<QrCodeConfBloc>().add(const QrCodeGenerateCodeRequested());
  }

  Future<void> _onRenamePressed(BuildContext context, QrLinkedCode code) async {
    final newName = await renameDialogOpener(context, initialName: code.name);
    if (!context.mounted || newName == null) {
      return;
    }

    context.read<QrCodeConfBloc>().add(QrCodeRenameCodeRequested(codeId: code.id, newName: newName));
  }

  void _onDeletePressed(BuildContext context, QrLinkedCode code) {
    context.read<QrCodeConfBloc>().add(QrCodeDeleteCodeRequested(codeId: code.id));
  }

  Future<void> _onPreviewPressed(BuildContext context, QrLinkedCode code) async {
    await previewDialogOpener(context, code: code);
  }
}
