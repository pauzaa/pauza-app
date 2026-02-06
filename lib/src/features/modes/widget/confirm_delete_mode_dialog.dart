import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/modes/bloc/modes_bloc.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ConfirmDeleteModeDialog extends StatelessWidget {
  const ConfirmDeleteModeDialog({required this.modeId, super.key});

  final String modeId;

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
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.deleteModeTitle),
      content: Text(l10n.deleteModeMessage),
      actions: <Widget>[
        PauzaTextButton(
          onPressed: () => close(context),
          title: Text(l10n.cancelButton),
        ),
        PauzaFilledButton(
          onPressed: () {
            context.read<ModesBloc>().add(ModesDeleteRequested(modeId: modeId));
            close(context);
          },
          title: Text(l10n.deleteModeButton),
        ),
      ],
    );
  }
}
