part of 'home_stats_bloc.dart';

final class HomeStatsState extends Equatable {
  const HomeStatsState({
    required this.isRefreshing,
    required this.streakDays,
    required this.focusedDuration,
    this.error,
  });

  const HomeStatsState.initial() : this(isRefreshing: false, streakDays: null, focusedDuration: null);

  final bool isRefreshing;
  final int? streakDays;
  final Duration? focusedDuration;
  final Object? error;

  bool get noDataAvailable => streakDays == null && focusedDuration == null;

  HomeStatsState copyWith({
    bool? isRefreshing,
    int? streakDays,
    Duration? focusedDuration,
    Object? error,
    bool clearError = false,
  }) {
    return HomeStatsState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      streakDays: streakDays ?? this.streakDays,
      focusedDuration: focusedDuration ?? this.focusedDuration,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[isRefreshing, streakDays, focusedDuration, error];
}
