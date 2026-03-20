import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:pauza/src/features/leaderboard/widget/leaderboard_entry_tile.dart';
import 'package:pauza/src/features/leaderboard/widget/leaderboard_podium.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class LeaderboardBody extends StatelessWidget {
  const LeaderboardBody({required this.state, super.key});

  final LeaderboardState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.entries.isEmpty) {
      return _LeaderboardError(state: state);
    }

    if (state.entries.isEmpty) {
      return const _LeaderboardEmpty();
    }

    final podiumEntries = state.podiumEntries;
    final listEntries = state.listEntries;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: LeaderboardPodium(entries: podiumEntries, tab: state.tab),
        ),
        if (listEntries.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium),
            sliver: SliverList.separated(
              itemCount: listEntries.length,
              separatorBuilder: (_, _) => const SizedBox(height: PauzaSpacing.small),
              itemBuilder: (context, index) {
                return LeaderboardEntryTile(entry: listEntries[index], tab: state.tab);
              },
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: PauzaSpacing.xLarge)),
      ],
    );
  }
}

class _LeaderboardError extends StatelessWidget {
  const _LeaderboardError({required this.state});

  final LeaderboardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(l10n.leaderboardErrorTitle, style: context.pauzaTextTheme.titleMedium),
          const SizedBox(height: PauzaSpacing.medium),
          FilledButton(
            onPressed: () => context.read<LeaderboardBloc>().add(const LeaderboardLoadRequested()),
            child: Text(l10n.leaderboardRetryButton),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEmpty extends StatelessWidget {
  const _LeaderboardEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Text(
        l10n.leaderboardEmptyTitle,
        style: context.pauzaTextTheme.titleMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
