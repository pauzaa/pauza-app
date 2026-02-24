import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/features/stats/blocking_stats/data/stats_blocking_repository.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
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
    on<StatsBlockingDateRangePicked>(_onDateRangePicked);
    on<StatsBlockingRefreshRequested>(_onRefreshRequested);
  }

  final StatsBlockingRepository _repository;
  final DateTime Function() _nowLocal;

  Future<void> _onStarted(StatsBlockingStarted event, Emitter<StatsBlockingState> emit) async {
    await _load(emit);
  }

  Future<void> _onDateRangePicked(StatsBlockingDateRangePicked event, Emitter<StatsBlockingState> emit) async {
    final picked = DateTimeRange(start: event.range.start.dayStart, end: event.range.end.dayEnd);
    emit(state.copyWith(window: picked));
    await _load(emit);
  }

  Future<void> _onRefreshRequested(StatsBlockingRefreshRequested event, Emitter<StatsBlockingState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<StatsBlockingState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final snapshot = await _repository.getBlockingSnapshot(window: state.window, nowLocal: _nowLocal());
      emit(state.copyWith(isLoading: false, snapshot: snapshot, clearError: true));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: error, clearSnapshot: true));
    }
  }
}
