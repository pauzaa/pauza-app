import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

class NfcChipConfScreen extends StatelessWidget {
  const NfcChipConfScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.nfcChipConfig);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
