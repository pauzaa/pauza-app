part of 'stats_usage_bloc.dart';

sealed class StatsUsageEvent {
  const StatsUsageEvent();
}

final class StatsUsageStarted extends StatsUsageEvent {
  const StatsUsageStarted();
}

final class StatsUsageDateRangePicked extends StatsUsageEvent {
  const StatsUsageDateRangePicked(this.range);

  final DateTimeRange range;
}

final class StatsUsageRefreshRequested extends StatsUsageEvent {
  const StatsUsageRefreshRequested();
}
