import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/features/stats/blocking_stats/data/stats_blocking_repository.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/mode_blocking_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/source_blocking_snapshot.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

part 'stats_blocking_event.dart';
part 'stats_blocking_state.dart';

class StatsBlockingBloc extends Bloc<StatsBlockingEvent, StatsBlockingState> {
  StatsBlockingBloc({
    required StatsBlockingRepository repository,
    DateTimeRange? initialRange,
    DateTime? maxDate,
    DateTime Function()? nowLocal,
  }) : _repository = repository,
       _nowLocal = nowLocal ?? DateTime.now,
       super(
         StatsBlockingState(window: initialRange ?? DateTime.now().pastWeek, maxDate: maxDate ?? DateTime.now().dayEnd),
       ) {
    on<StatsBlockingStarted>(_onStarted);
    on<StatsBlockingDateRangePicked>(_onDateRangePicked, transformer: restartable());
    on<StatsBlockingRefreshRequested>(_onRefreshRequested);
  }

  final StatsBlockingRepository _repository;
  final DateTime Function() _nowLocal;

  Future<void> _onStarted(StatsBlockingStarted event, Emitter<StatsBlockingState> emit) async {
    if (state.snapshot != null) return;
    await _load(emit);
  }

  Future<void> _onDateRangePicked(StatsBlockingDateRangePicked event, Emitter<StatsBlockingState> emit) async {
    final picked = DateTimeRange(start: event.range.start.dayStart, end: event.range.end.dayEnd);
    emit(
      state.copyWith(
        window: picked,
        isLoading: true,
        clearError: true,
        clearSnapshot: true,
        clearModeBreakdown: true,
        clearSourceBreakdown: true,
      ),
    );
    await _load(emit, skipLoadingEmit: true);
  }

  Future<void> _onRefreshRequested(StatsBlockingRefreshRequested event, Emitter<StatsBlockingState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<StatsBlockingState> emit, {bool skipLoadingEmit = false}) async {
    if (!skipLoadingEmit) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final window = state.window;
      final now = _nowLocal();

      // Fetch all three data sources in parallel.
      final (snapshot, modeBreakdown, sourceBreakdown) = await (
        _repository.getBlockingSnapshot(window: window, nowLocal: now),
        _repository.getModeBreakdown(window: window),
        _repository.getSourceBreakdown(window: window),
      ).wait;

      emit(
        state.copyWith(
          isLoading: false,
          snapshot: snapshot,
          modeBreakdown: modeBreakdown,
          sourceBreakdown: sourceBreakdown,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    }
  }
}
