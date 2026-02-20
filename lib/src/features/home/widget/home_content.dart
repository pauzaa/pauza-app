import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/model/home_dashboard_metrics.dart';
import 'package:pauza/src/features/home/widget/home_current_mode_card.dart';
import 'package:pauza/src/features/home/widget/home_pause_pill.dart';
import 'package:pauza/src/features/home/widget/home_pause_ring.dart';
import 'package:pauza/src/features/home/widget/home_session_button.dart';
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

    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: PauzaSpacing.large, horizontal: PauzaSpacing.large),
          children: <Widget>[
            PauzaDashboardAppBar(
              greeting: l10n.homeGreeting(DateTime.now().hour.toString()),
              title: l10n.homeDashboardTitle,
            ),

            Padding(
              padding: const EdgeInsets.only(top: PauzaSpacing.xLarge),
              child: BlocBuilder<BlockingBloc, BlockingState>(
                builder: (context, blockingState) {
                  if (blockingState.isPaused) {
                    return const HomePauseSession();
                  } else if (blockingState.isBlocking) {
                    return const HomeActiveSession();
                  }

                  return const HomeDefaultWidget();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeDefaultWidget extends StatelessWidget {
  const HomeDefaultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const metrics = HomeDashboardMetrics(streakDays: 5, focusedDuration: Duration(hours: 2, minutes: 15));
    return Column(
      children: [
        const Center(child: HomeStatsPill(metrics: metrics)),
        const SizedBox(height: PauzaSpacing.extraLarge),
        BlocSelector<ModesListBloc, ModesListState, Mode?>(
          selector: (state) => state.selectedMode,
          builder: (context, effectiveMode) {
            return BlocSelector<BlockingBloc, BlockingState, bool>(
              selector: (state) => state.isLoading,
              builder: (context, isBusy) {
                return HomeSessionButton(
                  isBusy: isBusy,
                  onTap: () => _onStartPressed(context: context, mode: effectiveMode, isBlocking: false),
                );
              },
            );
          },
        ),
        const SizedBox(height: PauzaSpacing.extraLarge),
        BlocBuilder<ModesListBloc, ModesListState>(
          builder: (context, modesState) {
            return BlocBuilder<BlockingBloc, BlockingState>(
              builder: (context, state) {
                return HomeCurrentModeCard(
                  modesState.selectedMode,
                  onTap: () => _onCurrentModePressed(context, modesState.items, modesState.selectedMode),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _onCurrentModePressed(BuildContext context, List<Mode> modes, Mode? selectedMode) async {
    final pickedMode = await ModePickerSheet.show(context, modes: modes, activeModeId: selectedMode?.id);
    if (pickedMode == null || !context.mounted) {
      return;
    }

    context.read<ModesListBloc>().add(ModesSelectionRequested(modeId: pickedMode.id));
  }

  void _onStartPressed({required BuildContext context, required Mode? mode, required bool isBlocking}) {
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
}

class HomePauseSession extends StatelessWidget {
  const HomePauseSession({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      spacing: PauzaSpacing.medium,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.pausedTitle.toUpperCase(),
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge?.copyWith(
            letterSpacing: 4,
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          l10n.pausedTakeABreathLabel.toUpperCase(),
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(letterSpacing: 2),
        ),
        BlocSelector<BlockingBloc, BlockingState, ({Duration? pauseTotalDuration, DateTime? pauseStartedAt})>(
          selector: (state) => (pauseTotalDuration: state.pauseTotalDuration, pauseStartedAt: state.pauseStartedAt),
          builder: (context, state) {
            return HomePauseRing(
              total: state.pauseTotalDuration ?? Duration.zero,
              startedAt: state.pauseStartedAt ?? DateTime.now(),
              subText: l10n.reminaingLabel.toUpperCase(),
            );
          },
        ),
        BlocSelector<BlockingBloc, BlockingState, bool>(
          selector: (state) => state.isLoading,
          builder: (context, isBusy) {
            return PauzaFilledButton(
              disabled: isBusy,
              onPressed: () {
                context.read<BlockingBloc>().add(const BlockingResumeRequested());
              },
              title: Text(l10n.homeResumeButtonLabel.toUpperCase()),
            );
          },
        ),
      ],
    );
  }
}

class HomeActiveSession extends StatelessWidget {
  const HomeActiveSession({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      spacing: PauzaSpacing.medium,
      children: [
        Text(
          l10n.homeSessionDurationLabel.toUpperCase(),
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge?.copyWith(
            letterSpacing: 4,
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),

        BlocSelector<BlockingBloc, BlockingState, DateTime?>(
          selector: (state) => state.sessionStartedAt,
          builder: (context, sessionStartedAt) {
            return StreamBuilder<DateTime>(
              stream: Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
              initialData: DateTime.now(),
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();
                final duration = switch (sessionStartedAt) {
                  final startedAt? => now.isAfter(startedAt) ? now.difference(startedAt) : Duration.zero,
                  null => Duration.zero,
                };

                return Text(
                  duration.formatTimerHhMmSs(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.displayLarge?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                );
              },
            );
          },
        ),
        BlocSelector<BlockingBloc, BlockingState, bool>(
          selector: (state) => state.isLoading,
          builder: (context, isBusy) {
            return HomeSessionButton(
              isActiveSession: true,
              isBusy: isBusy,
              onTap: () {
                context.read<BlockingBloc>().add(const BlockingStopRequested());
              },
            );
          },
        ),

        Text(
          l10n.homeQuickPauseLabel.toUpperCase(),
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.onSurfaceVariant, letterSpacing: 3),
        ),
        BlocSelector<BlockingBloc, BlockingState, bool>(
          selector: (state) => state.isLoading,
          builder: (context, isBusy) {
            return Row(
              spacing: PauzaSpacing.medium,
              children: <Widget>[
                Expanded(
                  child: HomePausePill(
                    minutes: 1,
                    isBusy: isBusy,
                    onTap: () {
                      context.read<BlockingBloc>().add(const BlockingQuickPauseRequested(Duration(minutes: 1)));
                    },
                  ),
                ),
                Expanded(
                  child: HomePausePill(
                    minutes: 5,
                    isBusy: isBusy,
                    onTap: () {
                      context.read<BlockingBloc>().add(const BlockingQuickPauseRequested(Duration(minutes: 5)));
                    },
                  ),
                ),
                Expanded(
                  child: HomePausePill(
                    minutes: 10,
                    isBusy: isBusy,
                    onTap: () {
                      context.read<BlockingBloc>().add(const BlockingQuickPauseRequested(Duration(minutes: 10)));
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
