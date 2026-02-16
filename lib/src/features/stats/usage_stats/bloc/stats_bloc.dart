import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_state.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_category_bucket.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_summary.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required StatsUsageRepository usageRepository,
    required this.platform,
    DateTimeRange? initialRange,
    DateTime? maxDate,
  }) : _usageRepository = usageRepository,
       super(
         StatsState(
           window: initialRange ?? DateTime.now().pastWeek,
           maxDate: maxDate ?? DateTime.now().dayEnd,
         ),
       ) {
    on<StatsStarted>(_onStarted);
    on<StatsDateRangePicked>(_onDateRangePicked);
    on<StatsRefreshRequested>(_onRefreshRequested);
  }

  final StatsUsageRepository _usageRepository;
  final PauzaPlatform platform;

  Future<void> _onStarted(StatsStarted event, Emitter<StatsState> emit) async {
    await _loadUsage(emit);
  }

  Future<void> _onDateRangePicked(StatsDateRangePicked event, Emitter<StatsState> emit) async {
    final picked = DateTimeRange(start: event.range.start.dayStart, end: event.range.end.dayEnd);
    emit(state.copyWith(window: picked));
    await _loadUsage(emit);
  }

  Future<void> _onRefreshRequested(StatsRefreshRequested event, Emitter<StatsState> emit) async {
    await _loadUsage(emit);
  }

  Future<void> _loadUsage(Emitter<StatsState> emit) async {
    if (platform == PauzaPlatform.ios) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final currentUsage = await _usageRepository.getUsageStats(
        start: state.window.start,
        end: state.window.end,
      );

      final previousWindow = state.window.shiftByInclusiveRange(-state.window.inclusiveDays);
      final previousUsage = await _usageRepository.getUsageStats(
        start: previousWindow.start,
        end: previousWindow.end,
      );

      emit(
        state.copyWith(
          isLoading: false,
          summary: _buildSummary(currentUsage, previousUsage, state.window),
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: error, clearSummary: true));
    }
  }

  UsageSummary _buildSummary(
    IList<UsageStats> current,
    IList<UsageStats> previous,
    DateTimeRange window,
  ) {
    final currentTotal = current.fold<Duration>(
      Duration.zero,
      (sum, item) => sum + item.totalDuration,
    );
    final previousTotal = previous.fold<Duration>(
      Duration.zero,
      (sum, item) => sum + item.totalDuration,
    );

    final bucketTotals = <UsageCategoryBucket, Duration>{
      UsageCategoryBucket.social: Duration.zero,
      UsageCategoryBucket.productivity: Duration.zero,
      UsageCategoryBucket.other: Duration.zero,
    };

    for (final item in current) {
      final bucket = UsageCategoryBucket.fromCategory(item.appInfo.category);
      bucketTotals[bucket] = (bucketTotals[bucket] ?? Duration.zero) + item.totalDuration;
    }

    final trendDurations = <DateTime, Duration>{};
    for (var i = 0; i < window.inclusiveDays; i++) {
      final day = window.start.add(Duration(days: i)).dayStart;
      trendDurations[day] = Duration.zero;
    }

    for (final item in current) {
      final basis = item.lastTimeUsed ?? item.bucketStart ?? window.start;
      final key = basis.dayStart;
      if (!trendDurations.containsKey(key)) {
        continue;
      }
      trendDurations[key] = (trendDurations[key] ?? Duration.zero) + item.totalDuration;
    }

    final trend =
        trendDurations.entries
            .map((entry) => UsageTrendPoint(day: entry.key, duration: entry.value))
            .toList(growable: false)
          ..sort((a, b) => a.day.compareTo(b.day));

    final deltaPercent = previousTotal.inMilliseconds == 0
        ? null
        : ((currentTotal.inMilliseconds - previousTotal.inMilliseconds) /
                  previousTotal.inMilliseconds) *
              100;

    return UsageSummary(
      totalDuration: currentTotal,
      dailyAverage: Duration(
        milliseconds: window.inclusiveDays == 0
            ? 0
            : currentTotal.inMilliseconds ~/ window.inclusiveDays,
      ),
      deltaPercent: deltaPercent,
      buckets: bucketTotals,
      trend: trend,
    );
  }
}
