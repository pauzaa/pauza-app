import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/nfc_chip_config/bloc/nfc_chip_conf_bloc.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_chip_conf_content.dart';

class NfcChipConfScreen extends StatelessWidget {
  const NfcChipConfScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.nfcChipConfig);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NfcChipConfBloc(linkedChipsRepository: RootScope.of(context).nfcLinkedChipsRepository)
            ..add(const NfcChipLoadCardsRequested()),
      child: const NfcChipConfContent(),
    );
  }
}
