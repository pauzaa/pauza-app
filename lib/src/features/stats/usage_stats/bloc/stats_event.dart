import 'package:flutter/material.dart';

sealed class StatsEvent {
  const StatsEvent();
}

final class StatsStarted extends StatsEvent {
  const StatsStarted();
}

final class StatsDateRangePicked extends StatsEvent {
  const StatsDateRangePicked(this.range);

  final DateTimeRange range;
}

final class StatsRefreshRequested extends StatsEvent {
  const StatsRefreshRequested();
}
