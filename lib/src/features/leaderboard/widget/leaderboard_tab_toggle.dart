import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class LeaderboardTabToggle extends StatelessWidget {
  const LeaderboardTabToggle({required this.selected, super.key});

  final LeaderboardTab selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium, vertical: PauzaSpacing.small),
      child: SegmentedButton<LeaderboardTab>(
        segments: <ButtonSegment<LeaderboardTab>>[
          ButtonSegment<LeaderboardTab>(
            value: LeaderboardTab.currentStreak,
            label: Text(l10n.leaderboardCurrentStreak),
          ),
          ButtonSegment<LeaderboardTab>(value: LeaderboardTab.totalFocus, label: Text(l10n.leaderboardTotalFocus)),
        ],
        selected: <LeaderboardTab>{selected},
        onSelectionChanged: (selection) {
          context.read<LeaderboardBloc>().add(LeaderboardTabChanged(selection.first));
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return context.colorScheme.primary;
            }
            return context.colorScheme.surfaceContainerHigh;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return context.colorScheme.onPrimary;
            }
            return context.colorScheme.onSurface;
          }),
        ),
      ),
    );
  }
}
