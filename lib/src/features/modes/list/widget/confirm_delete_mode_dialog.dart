import 'package:flutter/material.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

class ConfirmDeleteModeDialog extends StatelessWidget {
  const ConfirmDeleteModeDialog({super.key});

  static void show(BuildContext context, {required String modeId}) {
    HelmRouter.push(
      context,
      PauzaRoutes.modeDeleteConfirm,
      pathParams: <String, String>{'mid': modeId},
    );
  }

  static void close(BuildContext context) {
    HelmRouter.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
