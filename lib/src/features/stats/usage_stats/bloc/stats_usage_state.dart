part of 'stats_usage_bloc.dart';

final class StatsUsageState extends Equatable {
  const StatsUsageState({
    required this.window,
    required this.maxDate,
    this.isLoading = false,
    this.snapshot,
    this.dailyTrend,
    this.deviceEventSnapshot,
    this.error,
  });

  final DateTimeRange window;
  final DateTime maxDate;
  final bool isLoading;
  final UsageStatsSnapshot? snapshot;
  final IList<DailyUsagePoint>? dailyTrend;
  final DeviceEventSnapshot? deviceEventSnapshot;
  final Object? error;

  bool get hasError => error != null;
  bool get hasData => snapshot != null;

  StatsUsageState copyWith({
    DateTimeRange? window,
    DateTime? maxDate,
    bool? isLoading,
    UsageStatsSnapshot? snapshot,
    bool clearSnapshot = false,
    IList<DailyUsagePoint>? dailyTrend,
    bool clearDailyTrend = false,
    DeviceEventSnapshot? deviceEventSnapshot,
    bool clearDeviceEventSnapshot = false,
    Object? error,
    bool clearError = false,
  }) {
    return StatsUsageState(
      window: window ?? this.window,
      maxDate: maxDate ?? this.maxDate,
      isLoading: isLoading ?? this.isLoading,
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
      dailyTrend: clearDailyTrend ? null : (dailyTrend ?? this.dailyTrend),
      deviceEventSnapshot: clearDeviceEventSnapshot ? null : (deviceEventSnapshot ?? this.deviceEventSnapshot),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[window, maxDate, isLoading, snapshot, dailyTrend, deviceEventSnapshot, error];
}
