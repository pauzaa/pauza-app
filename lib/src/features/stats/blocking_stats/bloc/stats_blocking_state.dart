part of 'stats_blocking_bloc.dart';

final class StatsBlockingState extends Equatable {
  const StatsBlockingState({
    required this.window,
    required this.maxDate,
    this.isLoading = false,
    this.snapshot,
    this.modeBreakdown,
    this.sourceBreakdown,
    this.error,
  });

  final DateTimeRange window;
  final DateTime maxDate;
  final bool isLoading;
  final BlockingStatsSnapshot? snapshot;
  final ModeBlockingSnapshot? modeBreakdown;
  final SourceBlockingSnapshot? sourceBreakdown;
  final Object? error;

  bool get hasError => error != null;

  StatsBlockingState copyWith({
    DateTimeRange? window,
    DateTime? maxDate,
    bool? isLoading,
    BlockingStatsSnapshot? snapshot,
    bool clearSnapshot = false,
    ModeBlockingSnapshot? modeBreakdown,
    bool clearModeBreakdown = false,
    SourceBlockingSnapshot? sourceBreakdown,
    bool clearSourceBreakdown = false,
    Object? error,
    bool clearError = false,
  }) {
    return StatsBlockingState(
      window: window ?? this.window,
      maxDate: maxDate ?? this.maxDate,
      isLoading: isLoading ?? this.isLoading,
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
      modeBreakdown: clearModeBreakdown ? null : (modeBreakdown ?? this.modeBreakdown),
      sourceBreakdown: clearSourceBreakdown ? null : (sourceBreakdown ?? this.sourceBreakdown),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[window, maxDate, isLoading, snapshot, modeBreakdown, sourceBreakdown, error];
}
