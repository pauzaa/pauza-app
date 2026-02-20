part of 'home_stats_bloc.dart';

sealed class HomeStatsEvent extends Equatable {
  const HomeStatsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class HomeStatsLoadRequested extends HomeStatsEvent {
  const HomeStatsLoadRequested();
}

final class HomeStatsLifecycleActionReceived extends HomeStatsEvent {
  const HomeStatsLifecycleActionReceived(this.action);

  final RestrictionLifecycleAction action;

  @override
  List<Object?> get props => <Object?>[action];
}
