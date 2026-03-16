part of 'leaderboard_bloc.dart';

sealed class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class LeaderboardLoadRequested extends LeaderboardEvent {
  const LeaderboardLoadRequested();
}

final class LeaderboardTabChanged extends LeaderboardEvent {
  const LeaderboardTabChanged(this.tab);

  final LeaderboardTab tab;

  @override
  List<Object?> get props => <Object?>[tab];
}
