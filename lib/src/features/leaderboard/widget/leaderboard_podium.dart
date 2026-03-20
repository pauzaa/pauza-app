import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_entry_dto.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_entry_formatting.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({required this.entries, required this.tab, super.key});

  final List<LeaderboardEntryDto> entries;
  final LeaderboardTab tab;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final rank1 = entries.where((e) => e.rank == 1).firstOrNull;
    final rank2 = entries.where((e) => e.rank == 2).firstOrNull;
    final rank3 = entries.where((e) => e.rank == 3).firstOrNull;

    return Container(
      margin: const EdgeInsets.all(PauzaSpacing.medium),
      padding: const EdgeInsets.only(top: PauzaSpacing.large, left: PauzaSpacing.small, right: PauzaSpacing.small),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.xLarge),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[context.colorScheme.primary.withValues(alpha: 0.15), context.colorScheme.surface],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (rank2 != null)
            Expanded(
              child: _PodiumColumn(entry: rank2, tab: tab),
            )
          else
            const Spacer(),
          if (rank1 != null)
            Expanded(
              child: _PodiumColumn(entry: rank1, tab: tab),
            )
          else
            const Spacer(),
          if (rank3 != null)
            Expanded(
              child: _PodiumColumn(entry: rank3, tab: tab),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({required this.entry, required this.tab});

  final LeaderboardEntryDto entry;
  final LeaderboardTab tab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isFirst = entry.rank == 1;
    final avatarRadius = isFirst ? PauzaAvatarSizes.xLarge : PauzaAvatarSizes.large;
    final pedestalHeight = switch (entry.rank) {
      1 => 80.0,
      2 => 56.0,
      _ => 40.0,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isFirst) Icon(Icons.emoji_events_rounded, color: context.colorScheme.primary, size: PauzaIconSizes.xLarge),
        const SizedBox(height: PauzaSpacing.small),
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: <Widget>[
            PauzaUserAvatar(imageUrl: entry.user.profilePictureUrl, radius: avatarRadius, borderWidth: isFirst ? 3 : 2),
            Positioned(
              bottom: -8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: context.colorScheme.primary, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '${entry.rank}',
                  style: context.pauzaTextTheme.labelSmall.copyWith(
                    color: context.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: PauzaSpacing.regular),
        Text(
          entry.user.name,
          style: context.pauzaTextTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PauzaSpacing.tiny),
        Text(
          entry.formatStat(l10n, tab),
          style: context.pauzaTextTheme.bodySmall.copyWith(color: context.colorScheme.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PauzaSpacing.small),
        Container(
          height: pedestalHeight,
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(PauzaCornerRadius.medium)),
          ),
        ),
      ],
    );
  }
}
