import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';

class ConfirmDeleteModeDialog extends StatelessWidget {
  const ConfirmDeleteModeDialog({required this.modeId, super.key});

  final String? modeId;

  static void show(BuildContext context, {required String modeId}) {
    HelmRouter.push(
      context,
      PauzaRoutes.modeDeleteConfirm,
      queryParams: <String, String>{'mid': modeId},
    );
  }

  static void close(BuildContext context) {
    HelmRouter.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canDelete = modeId != null && modeId!.isNotEmpty;

    return AlertDialog(
      title: Text(l10n.deleteModeTitle),
      content: Text(l10n.deleteModeMessage),
      actions: [
        TextButton(
          onPressed: () => close(context),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: canDelete
              ? () {
                  context.read<ModesListBloc>().add(
                    ModesDeleteRequested(modeId: modeId!),
                  );
                  close(context);
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text(l10n.deleteModeButton),
        ),
      ],
    );
  }
}
