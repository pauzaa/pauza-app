import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/bloc/stats_state.dart';
import 'package:pauza/src/features/stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/model/stats_date_window.dart';
import 'package:pauza/src/features/stats/model/stats_tab.dart';
import 'package:pauza/src/features/stats/model/usage_category_bucket.dart';
import 'package:pauza/src/features/stats/model/usage_summary.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required StatsUsageRepository usageRepository,
    PauzaPlatform? platform,
    DateTime Function()? now,
  }) : _usageRepository = usageRepository,
       _now = now ?? DateTime.now,
       super(
         StatsState(
           platform: platform ?? kPauzaPlatform,
           selectedTab: StatsTab.usage,
           window: StatsDateWindow.currentIsoWeek((now ?? DateTime.now).call()),
           maxDate: StatsDateWindow.atDayEnd((now ?? DateTime.now).call()),
         ),
       ) {
    on<StatsStarted>(_onStarted);
    on<StatsTabChanged>(_onTabChanged);
    on<StatsDateRangePicked>(_onDateRangePicked);
    on<StatsDateRangeShifted>(_onDateRangeShifted);
    on<StatsRefreshRequested>(_onRefreshRequested);
  }

  final StatsUsageRepository _usageRepository;
  final DateTime Function() _now;

  Future<void> _onStarted(StatsStarted event, Emitter<StatsState> emit) async {
    emit(
      state.copyWith(
        window: StatsDateWindow.currentIsoWeek(_now()),
        maxDate: StatsDateWindow.atDayEnd(_now()),
      ),
    );
    await _loadUsage(emit);
  }

  void _onTabChanged(StatsTabChanged event, Emitter<StatsState> emit) {
    emit(state.copyWith(selectedTab: event.tab));
  }

  Future<void> _onDateRangePicked(
    StatsDateRangePicked event,
    Emitter<StatsState> emit,
  ) async {
    final picked = StatsDateWindow(
      start: StatsDateWindow.atDayStart(event.range.start),
      end: StatsDateWindow.atDayEnd(event.range.end),
    );
    emit(state.copyWith(window: picked));
    await _loadUsage(emit);
  }

  Future<void> _onDateRangeShifted(
    StatsDateRangeShifted event,
    Emitter<StatsState> emit,
  ) async {
    final days = state.window.inclusiveDays * event.direction;
    final shifted = state.window.shiftByDays(days);
    if (shifted.end.isAfter(state.maxDate)) {
      return;
    }
    emit(state.copyWith(window: shifted));
    await _loadUsage(emit);
  }

  Future<void> _onRefreshRequested(
    StatsRefreshRequested event,
    Emitter<StatsState> emit,
  ) async {
    await _loadUsage(emit);
  }

  Future<void> _loadUsage(Emitter<StatsState> emit) async {
    if (state.platform == PauzaPlatform.ios) {
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        hasMissingPermission: false,
      ),
    );

    try {
      final currentUsage = await _usageRepository.getUsageStats(
        start: state.window.start,
        end: state.window.end,
      );

      final previousWindow = state.window.shiftByDays(
        -state.window.inclusiveDays,
      );
      final previousUsage = await _usageRepository.getUsageStats(
        start: previousWindow.start,
        end: previousWindow.end,
      );

      emit(
        state.copyWith(
          isLoading: false,
          summary: _buildSummary(currentUsage, previousUsage, state.window),
          clearError: true,
          hasMissingPermission: false,
        ),
      );
    } on Object catch (error) {
      final isMissingPermission = error is PauzaMissingPermissionError;
      emit(
        state.copyWith(
          isLoading: false,
          error: error,
          hasMissingPermission: isMissingPermission,
          clearSummary: true,
        ),
      );
    }
  }

  UsageSummary _buildSummary(
    List<UsageStats> current,
    List<UsageStats> previous,
    StatsDateWindow window,
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
      final bucket = _bucketForCategory(item.appInfo.category);
      bucketTotals[bucket] =
          (bucketTotals[bucket] ?? Duration.zero) + item.totalDuration;
    }

    final trendDurations = <DateTime, Duration>{};
    for (var i = 0; i < window.inclusiveDays; i++) {
      final day = StatsDateWindow.atDayStart(
        window.start.add(Duration(days: i)),
      );
      trendDurations[day] = Duration.zero;
    }

    for (final item in current) {
      final basis = item.lastTimeUsed ?? item.bucketStart ?? window.start;
      final key = StatsDateWindow.atDayStart(basis);
      if (!trendDurations.containsKey(key)) {
        continue;
      }
      trendDurations[key] =
          (trendDurations[key] ?? Duration.zero) + item.totalDuration;
    }

    final trend =
        trendDurations.entries
            .map(
              (entry) => UsageTrendPoint(day: entry.key, duration: entry.value),
            )
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

  UsageCategoryBucket _bucketForCategory(String? category) {
    if (category == null) {
      return UsageCategoryBucket.other;
    }
    final normalized = category.toLowerCase();

    if (normalized.contains('social') ||
        normalized.contains('communication') ||
        normalized.contains('messaging')) {
      return UsageCategoryBucket.social;
    }

    if (normalized.contains('productivity') ||
        normalized.contains('business') ||
        normalized.contains('education') ||
        normalized.contains('tools')) {
      return UsageCategoryBucket.productivity;
    }

    return UsageCategoryBucket.other;
  }
}
