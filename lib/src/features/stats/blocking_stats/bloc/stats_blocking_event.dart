part of 'stats_blocking_bloc.dart';

sealed class StatsBlockingEvent {
  const StatsBlockingEvent();
}

final class StatsBlockingStarted extends StatsBlockingEvent {
  const StatsBlockingStarted();
}

final class StatsBlockingDateRangePicked extends StatsBlockingEvent {
  const StatsBlockingDateRangePicked(this.range);

  final DateTimeRange range;
}

final class StatsBlockingRefreshRequested extends StatsBlockingEvent {
  const StatsBlockingRefreshRequested();
}
