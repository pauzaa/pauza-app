import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:pauza/src/core/common/extensions.dart';
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
                final effectiveMode = resolve(
                  modesState: modesState,
                  blockingState: blockingState,
                );

                final isBusy = modesState.isLoading || blockingState.isLoading;
                final isActiveSession = blockingState.isBlocking;

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: PauzaSpacing.large,
                    horizontal: PauzaSpacing.large,
                  ),
                  children: <Widget>[
                    PauzaDashboardAppBar(
                      greeting: l10n.homeGreeting(
                        DateTime.now().hour.toString(),
                      ),
                      title: l10n.homeDashboardTitle,
                      showSettingsButton: false,
                      padding: EdgeInsets.zero,
                    ),
                    if (isActiveSession) ...<Widget>[
                      const SizedBox(height: PauzaSpacing.extraLarge),
                      Text(
                        l10n.homeSessionDurationLabel.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleLarge?.copyWith(
                          letterSpacing: 4,
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: PauzaSpacing.medium),
                      StreamBuilder<DateTime>(
                        stream: Stream<DateTime>.periodic(
                          const Duration(seconds: 1),
                          (_) => DateTime.now(),
                        ),
                        initialData: DateTime.now(),
                        builder: (context, snapshot) {
                          final now = snapshot.data ?? DateTime.now();
                          final duration =
                              switch (blockingState.sessionStartedAt) {
                                final startedAt? =>
                                  now.isAfter(startedAt)
                                      ? now.difference(startedAt)
                                      : Duration.zero,
                                null => Duration.zero,
                              };

                          return Text(
                            duration.formatTimerHhMmSs(),
                            textAlign: TextAlign.center,
                            style: context.textTheme.displayLarge?.copyWith(
                              color: context.colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: PauzaSpacing.extraLarge),
                      Center(
                        child: HomeStartSessionButton(
                          isActiveSession: true,
                          onTap: isBusy
                              ? null
                              : () {
                                  context.read<BlockingBloc>().add(
                                    const BlockingStopRequested(),
                                  );
                                },
                        ),
                      ),
                      const SizedBox(height: PauzaSpacing.extraLarge),
                      if (blockingState.isPaused) ...<Widget>[
                        FilledButton(
                          onPressed: isBusy
                              ? null
                              : () {
                                  context.read<BlockingBloc>().add(
                                    const BlockingResumeRequested(),
                                  );
                                },
                          child: Text(l10n.homeResumeButtonLabel.toUpperCase()),
                        ),
                      ] else ...<Widget>[
                        Text(
                          l10n.homeQuickPauseLabel.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: PauzaSpacing.medium),
                        Row(
                          spacing: PauzaSpacing.medium,
                          children: <Widget>[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isBusy
                                    ? null
                                    : () {
                                        context.read<BlockingBloc>().add(
                                          const BlockingQuickPauseRequested(
                                            Duration(minutes: 1),
                                          ),
                                        );
                                      },
                                child: const Text('1m'),
                              ),
                            ),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isBusy
                                    ? null
                                    : () {
                                        context.read<BlockingBloc>().add(
                                          const BlockingQuickPauseRequested(
                                            Duration(minutes: 5),
                                          ),
                                        );
                                      },
                                child: const Text('5m'),
                              ),
                            ),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isBusy
                                    ? null
                                    : () {
                                        context.read<BlockingBloc>().add(
                                          const BlockingQuickPauseRequested(
                                            Duration(minutes: 10),
                                          ),
                                        );
                                      },
                                child: const Text('10m'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ] else ...<Widget>[
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
                        onTap: () =>
                            _onCurrentModePressed(context, modesState.items),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _onCurrentModePressed(
    BuildContext context,
    List<Mode> modes,
  ) async {
    final selectedMode = await ModePickerSheet.show(context, modes: modes);
    if (selectedMode == null || !context.mounted) {
      return;
    }

    context.read<ModesListBloc>().add(
      ModesSelectionRequested(modeId: selectedMode.id),
    );
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

  Mode? resolve({
    required ModesListState modesState,
    required BlockingState blockingState,
  }) {
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
