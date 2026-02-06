import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/modes/bloc/modes_bloc.dart';
import 'package:pauza/src/features/modes/model/mode_summary.dart';
import 'package:pauza/src/features/modes/widget/confirm_delete_mode_dialog.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ModePickerSheet extends StatelessWidget {
  const ModePickerSheet({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.modePicker);
  }

  static void close(BuildContext context) {
    HelmRouter.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.selectModeTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                PauzaIconButton(
                  onPressed: () => close(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: BlocBuilder<ModesBloc, ModesState>(
                builder: (context, state) {
                  if (state.items.isEmpty) {
                    return Center(child: Text(l10n.noModesEmptyState));
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final summary = state.items[index];
                      return _ModeRow(summary: summary);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PauzaOutlinedButton(
                onPressed: () => _showComingSoon(context),
                title: Text(l10n.addModeButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.comingSoonMessage)));
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({required this.summary});

  final ModeSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSelected = context.select<ModesBloc, bool>(
      (bloc) => bloc.state.selectedModeId == summary.mode.id,
    );

    return ListTile(
      title: Text(summary.mode.title),
      subtitle: Text(l10n.blockedAppsCountLabel(summary.blockedAppsCount)),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      ),
      onTap: () {
        context.read<ModesBloc>().add(
          ModesSelectionChanged(modeId: summary.mode.id),
        );
        ModePickerSheet.close(context);
      },
      trailing: PopupMenuButton<_ModeAction>(
        onSelected: (value) {
          switch (value) {
            case _ModeAction.edit:
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.comingSoonMessage)));
            case _ModeAction.delete:
              ConfirmDeleteModeDialog.show(context, modeId: summary.mode.id);
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<_ModeAction>>[
          PopupMenuItem<_ModeAction>(
            value: _ModeAction.edit,
            child: Text(l10n.editModeButton),
          ),
          PopupMenuItem<_ModeAction>(
            value: _ModeAction.delete,
            child: Text(l10n.deleteModeButton),
          ),
        ],
      ),
    );
  }
}

enum _ModeAction { edit, delete }
