part of 'stats_blocking_bloc.dart';

final class StatsBlockingState extends Equatable {
  const StatsBlockingState({
    required this.window,
    required this.maxDate,
    this.isLoading = false,
    this.snapshot,
    this.error,
  });

  final DateTimeRange window;
  final DateTime maxDate;
  final bool isLoading;
  final BlockingStatsSnapshot? snapshot;
  final Object? error;

  bool get hasError => error != null;

  StatsBlockingState copyWith({
    DateTimeRange? window,
    DateTime? maxDate,
    bool? isLoading,
    BlockingStatsSnapshot? snapshot,
    bool clearSnapshot = false,
    Object? error,
    bool clearError = false,
  }) {
    return StatsBlockingState(
      window: window ?? this.window,
      maxDate: maxDate ?? this.maxDate,
      isLoading: isLoading ?? this.isLoading,
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[window, maxDate, isLoading, snapshot, error];
}
