import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/friends/common/model/friend_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_stats_dto.dart';
import 'package:pauza/src/features/friends/friends_list/widget/friend_activity_trend_bar.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({required this.friend, this.stats, super.key});

  final FriendDto friend;
  final FriendStatsDto? stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = context.pauzaColorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PauzaUserAvatar(imageUrl: friend.user.profilePictureUrl, radius: PauzaAvatarSizes.small),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(friend.user.name, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                      Text(
                        '@${friend.user.username}',
                        style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (stats != null) ...[
                  Icon(Icons.local_fire_department_rounded, size: 18, color: colors.warning),
                  const SizedBox(width: 4),
                  Text(
                    l10n.friendsStreakDays(stats!.currentStreakDays),
                    style: textTheme.labelMedium?.copyWith(color: colors.warning),
                  ),
                ],
              ],
            ),
            if (stats != null) ...[
              const SizedBox(height: 8),
              if (stats!.longestStreakDays > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Text(
                    l10n.friendsLongestStreak(stats!.longestStreakDays),
                    style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Row(
                  children: [
                    _StatChip(label: l10n.friendsTodayLabel, value: _formatMs(context, stats!.focusTimeTodayMs)),
                    const SizedBox(width: 12),
                    _StatChip(label: l10n.friendsAllTimeLabel, value: _formatMs(context, stats!.totalFocusTimeMs)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.friendsTrendLabel,
                            style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          FriendActivityTrendBar(trends: stats!.dailyTrends),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatMs(BuildContext context, int ms) {
    final l10n = context.l10n;
    final totalMinutes = ms ~/ 60000;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) return l10n.durationHoursMinutes(hours, minutes);
    return l10n.durationMinutes(minutes);
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.pauzaColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: textTheme.labelLarge),
      ],
    );
  }
}
