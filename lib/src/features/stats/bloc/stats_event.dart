import 'package:flutter/material.dart';
import 'package:pauza/src/features/stats/model/stats_tab.dart';

sealed class StatsEvent {
  const StatsEvent();
}

final class StatsStarted extends StatsEvent {
  const StatsStarted();
}

final class StatsTabChanged extends StatsEvent {
  const StatsTabChanged(this.tab);

  final StatsTab tab;
}

final class StatsDateRangePicked extends StatsEvent {
  const StatsDateRangePicked(this.range);

  final DateTimeRange range;
}

final class StatsDateRangeShifted extends StatsEvent {
  const StatsDateRangeShifted(this.direction);

  final int direction;
}

final class StatsRefreshRequested extends StatsEvent {
  const StatsRefreshRequested();
}
