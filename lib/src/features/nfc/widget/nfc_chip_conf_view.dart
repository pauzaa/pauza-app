import 'package:flutter/material.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/nfc/widget/nfc_chip_conf_target_visual.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class NfcChipConfView extends StatefulWidget {
  const NfcChipConfView({super.key});

  @override
  State<NfcChipConfView> createState() => _NfcChipConfViewState();
}

class _NfcChipConfViewState extends State<NfcChipConfView> {
  @override
  void initState() {
    startScanning();
    super.initState();
  }

  @override
  void dispose() {
    PauzaDependencies.of(context).nfcRepository.stopSession();
    super.dispose();
  }

  Future<void> startScanning() async {
    try {
      final card = await PauzaDependencies.of(
        context,
      ).nfcRepository.scanSingleCard();
      if (mounted) {
        Navigator.of(context).pop(card);
      }
    } on Object catch (error) {
      if (mounted) {
        if (error case final Localizable error) {
          context.showToast(error.localize(context.l10n));
        } else {
          context.showToast(context.l10n.nfcChipConfigScanFailed);
        }
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BottomSheetScaffold(
      bodyPadding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.large),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: PauzaSpacing.large,
        children: [
          Text(
            l10n.readyToScanNfcTag,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const NfcChipConfTargetVisual(size: 300),
          Text(
            l10n.nfcChipHoldCardNearDevice,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          PauzaFilledButton(
            title: Text(l10n.cancelButton),
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }
}
