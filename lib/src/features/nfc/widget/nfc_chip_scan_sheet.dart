import 'package:flutter/material.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';
import 'package:pauza/src/features/nfc/widget/nfc_chip_conf_view.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class NfcChipScanSheet extends StatelessWidget {
  const NfcChipScanSheet({super.key});

  static Future<NfcCardDto?> show(BuildContext context, {NfcRepository? repository}) async {
    final nfcRepository = repository ?? PauzaDependencies.of(context).nfcRepository;
    final availability = await nfcRepository.getAvailability();
    if (!context.mounted) {
      return null;
    }
    final canOpenSettings = nfcRepository.canOpenSystemSettingsForNfc;
    if (availability != NfcChipAvailability.available) {
      await PauzaAlertDialog.show(
        context,
        title: availability.localizedTitle(context.l10n),
        body: availability.localizedBody(context.l10n),
        primaryActionLabel:
            availability.localizedActionLabel(context.l10n, canOpenSettings: canOpenSettings) ?? context.l10n.okButton,
        onPrimaryActionPressed: () {
          if (availability.shouldShowOpenSettings(canOpenSettings: canOpenSettings)) {
            nfcRepository.openSystemSettingsForNfc();
          } else {
            Navigator.of(context).pop();
          }
        },
        secondaryActionLabel: availability.shouldShowOpenSettings(canOpenSettings: canOpenSettings)
            ? context.l10n.cancelButton
            : null,
      );
      return null;
    }
    return showModalBottomSheet<NfcCardDto>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) => const NfcChipScanSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const NfcChipConfView();
  }
}
