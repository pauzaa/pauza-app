part of 'leaderboard_bloc.dart';

enum LeaderboardTab { currentStreak, totalFocus }

final class LeaderboardState extends Equatable {
  const LeaderboardState({required this.tab, required this.isLoading, required this.entries, this.myRank, this.error});

  const LeaderboardState.initial()
    : this(tab: LeaderboardTab.currentStreak, isLoading: false, entries: const <LeaderboardEntryDto>[]);

  final LeaderboardTab tab;
  final bool isLoading;
  final List<LeaderboardEntryDto> entries;
  final LeaderboardRankDto? myRank;
  final Object? error;

  List<LeaderboardEntryDto> get podiumEntries => entries.where((e) => e.rank <= 3).toList(growable: false);

  List<LeaderboardEntryDto> get listEntries => entries.where((e) => e.rank > 3).toList(growable: false);

  LeaderboardState copyWith({
    LeaderboardTab? tab,
    bool? isLoading,
    List<LeaderboardEntryDto>? entries,
    LeaderboardRankDto? myRank,
    Object? error,
    bool clearError = false,
  }) {
    return LeaderboardState(
      tab: tab ?? this.tab,
      isLoading: isLoading ?? this.isLoading,
      entries: entries ?? this.entries,
      myRank: myRank ?? this.myRank,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[tab, isLoading, entries, myRank, error];
}
