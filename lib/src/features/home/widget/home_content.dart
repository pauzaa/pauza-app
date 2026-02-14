import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/model/home_dashboard_metrics.dart';
import 'package:pauza/src/features/home/widget/home_current_mode_card.dart';
import 'package:pauza/src/features/home/widget/home_start_session_button.dart';
import 'package:pauza/src/features/home/widget/home_stats_pill.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza/src/features/modes/list/widget/mode_picker_sheet.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    const metrics = HomeDashboardMetrics(
      streakDays: 5,
      focusedDuration: Duration(hours: 2, minutes: 15),
    );

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ModesListBloc, ModesListState>(
          builder: (context, modesState) {
            return BlocBuilder<BlockingBloc, BlockingState>(
              builder: (context, blockingState) {
                final effectiveMode = resolve(modesState: modesState, blockingState: blockingState);

                final isBusy = modesState.isLoading || blockingState.isLoading;

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: PauzaSpacing.large,
                    horizontal: PauzaSpacing.large,
                  ),
                  children: <Widget>[
                    PauzaDashboardAppBar(
                      greeting: l10n.homeGreeting(DateTime.now().hour.toString()),
                      title: l10n.homeDashboardTitle,
                      showSettingsButton: false,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: PauzaSpacing.large),
                    const Center(child: HomeStatsPill(metrics: metrics)),
                    const SizedBox(height: PauzaSpacing.extraLarge),
                    HomeStartSessionButton(
                      onTap: isBusy
                          ? null
                          : () {
                              _onStartPressed(
                                context: context,
                                mode: effectiveMode,
                                isBlocking: blockingState.isBlocking,
                              );
                            },
                    ),
                    const SizedBox(height: PauzaSpacing.extraLarge),
                    HomeCurrentModeCard(
                      effectiveMode,
                      onTap: () => _onCurrentModePressed(context, modesState.items),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _onCurrentModePressed(BuildContext context, List<Mode> modes) async {
    final selectedMode = await ModePickerSheet.show(context, modes: modes);
    if (selectedMode == null || !context.mounted) {
      return;
    }

    context.read<ModesListBloc>().add(ModesSelectionRequested(modeId: selectedMode.id));
  }

  void _onStartPressed({
    required BuildContext context,
    required Mode? mode,
    required bool isBlocking,
  }) {
    if (isBlocking) {
      context.showToast(context.l10n.alreadyBlocking);
      return;
    }

    if (mode == null) {
      context.showToast(context.l10n.selectMode);
      return;
    }
    context.read<BlockingBloc>().add(BlockingStartRequested(mode));
  }

  Mode? resolve({required ModesListState modesState, required BlockingState blockingState}) {
    if (modesState.selectedMode case final selected?) {
      return selected;
    }

    if (blockingState.activeModeId case final activeModeId?) {
      for (final mode in modesState.items) {
        if (mode.id == activeModeId) {
          return mode;
        }
      }
    }

    return modesState.items.firstOrNull;
  }
}
