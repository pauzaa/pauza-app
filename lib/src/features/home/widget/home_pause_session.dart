import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/widget/home_pause_ring.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

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
