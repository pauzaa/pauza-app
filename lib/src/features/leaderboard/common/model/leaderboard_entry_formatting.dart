import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_entry_dto.dart';

extension LeaderboardEntryFormatting on LeaderboardEntryDto {
  String formatStat(AppLocalizations l10n, LeaderboardTab tab) {
    return switch (tab) {
      LeaderboardTab.currentStreak => l10n.leaderboardDaysCount(currentStreakDays ?? 0),
      LeaderboardTab.totalFocus => _formatFocusTime(l10n),
    };
  }

  String _formatFocusTime(AppLocalizations l10n) {
    final totalMinutes = (totalFocusTimeMs ?? 0) ~/ 60000;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      return '${l10n.leaderboardHoursCount(hours)} ${l10n.leaderboardMinutesCount(minutes)}';
    }
    return l10n.leaderboardMinutesCount(minutes);
  }
}
