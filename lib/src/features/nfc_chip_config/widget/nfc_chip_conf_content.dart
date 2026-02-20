import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/widget/nfc_chip_scan_sheet.dart';
import 'package:pauza/src/features/nfc_chip_config/bloc/nfc_chip_conf_bloc.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_chip_rename_dialog.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_linked_chip_list.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class NfcChipConfContent extends StatelessWidget {
  const NfcChipConfContent({
    super.key,
    this.scanSheetOpener = NfcChipScanSheet.show,
    this.renameDialogOpener = NfcChipRenameDialog.show,
  });

  final Future<NfcCardDto?> Function(BuildContext context) scanSheetOpener;
  final Future<String?> Function(
    BuildContext context, {
    required String initialName,
  })
  renameDialogOpener;

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcChipConfBloc, NfcChipConfState>(
      listenWhen: (previous, current) => previous != current && current.isError,
      listener: (context, state) {
        switch (state) {
          case NfcChipConfIdle():
          case NfcChipConfLoading():
          case NfcChipConfSuccess():
            break;
          case NfcChipConfError():
            if (state.error case final Localizable localizableError) {
              context.showToast(localizableError.localize(context.l10n));
            } else {
              context.showToast(context.l10n.nfcChipConfigScanFailed);
            }
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.nfcChipConfigTagsTitle)),
        body: BlocBuilder<NfcChipConfBloc, NfcChipConfState>(
          builder: (context, state) {
            return Stack(
              children: [
                AbsorbPointer(
                  absorbing: state.isLoading,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PauzaSpacing.large,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: PauzaSpacing.large,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.nfcChipConfigTagsBody,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Expanded(
                          child: NfcLinkedChipList(
                            linkedChips: state.linkedChips,
                            isLoading: state.isLoading,
                            onRenamePressed: (chip) =>
                                _onRenamePressed(context, chip),
                            onDeletePressed: (chip) =>
                                _onDeletePressed(context, chip),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.isLoading)
                  const Align(
                    alignment: Alignment.topCenter,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
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
          child: BlocSelector<NfcChipConfBloc, NfcChipConfState, bool>(
            selector: (state) => state.isLoading,
            builder: (context, isLoading) {
              return PauzaFilledButton(
                onPressed: () => _onLinkPressed(context),
                disabled: isLoading,
                size: PauzaButtonSize.large,
                icon: const Icon(Icons.add_circle),
                textStyle: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                title: Text(context.l10n.nfcChipConfigLinkNewTagButton),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onLinkPressed(BuildContext context) async {
    final card = await scanSheetOpener(context);
    if (!context.mounted || card == null) {
      return;
    }

    context.read<NfcChipConfBloc>().add(NfcChipLinkCardRequested(card: card));
  }

  Future<void> _onRenamePressed(
    BuildContext context,
    NfcLinkedChip chip,
  ) async {
    final newName = await renameDialogOpener(context, initialName: chip.name);
    if (!context.mounted || newName == null) {
      return;
    }

    context.read<NfcChipConfBloc>().add(
      NfcChipRenameCardRequested(cardId: chip.id, newName: newName),
    );
  }

  void _onDeletePressed(BuildContext context, NfcLinkedChip chip) {
    context.read<NfcChipConfBloc>().add(
      NfcChipDeleteCardRequested(cardId: chip.id),
    );
  }
}
