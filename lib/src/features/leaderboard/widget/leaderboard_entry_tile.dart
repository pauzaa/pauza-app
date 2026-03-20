import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_entry_dto.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_entry_formatting.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class LeaderboardEntryTile extends StatelessWidget {
  const LeaderboardEntryTile({required this.entry, required this.tab, super.key});

  final LeaderboardEntryDto entry;
  final LeaderboardTab tab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(PauzaSpacing.medium),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        border: Border.all(color: context.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: context.pauzaTextTheme.titleMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: PauzaSpacing.regular),
          PauzaUserAvatar(imageUrl: entry.user.profilePictureUrl, radius: PauzaAvatarSizes.small, borderWidth: 2),
          const SizedBox(width: PauzaSpacing.regular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.user.name,
                  style: context.pauzaTextTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '@${entry.user.username}',
                  style: context.pauzaTextTheme.bodySmall.copyWith(color: context.colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: PauzaSpacing.small),
          Text(
            entry.formatStat(l10n, tab),
            style: context.pauzaTextTheme.titleMedium.copyWith(color: context.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
