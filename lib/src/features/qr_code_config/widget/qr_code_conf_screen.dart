import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

class QrCodeConfScreen extends StatelessWidget {
  const QrCodeConfScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.qrCodeConfig);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
