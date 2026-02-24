import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

part 'home_stats_event.dart';
part 'home_stats_state.dart';

class HomeStatsBloc extends Bloc<HomeStatsEvent, HomeStatsState> {
  HomeStatsBloc({
    required StreaksRepository streaksRepository,
    required Stream<RestrictionLifecycleAction> lifecycleActions,
    DateTime Function()? nowLocal,
  }) : _streaksRepository = streaksRepository,
       _nowLocal = nowLocal ?? DateTime.now,
       super(const HomeStatsState.initial()) {
    on<HomeStatsLoadRequested>(_onLoadRequested);
    on<HomeStatsLifecycleActionReceived>(_onLifecycleActionReceived);

    _lifecycleActionsSubscription = lifecycleActions.listen((action) {
      if (isClosed) {
        return;
      }
      add(HomeStatsLifecycleActionReceived(action));
    });
  }

  final StreaksRepository _streaksRepository;
  final DateTime Function() _nowLocal;
  late final StreamSubscription<RestrictionLifecycleAction> _lifecycleActionsSubscription;

  Future<void> _onLoadRequested(HomeStatsLoadRequested event, Emitter<HomeStatsState> emit) {
    return _refreshStats(emit);
  }

  Future<void> _onLifecycleActionReceived(HomeStatsLifecycleActionReceived event, Emitter<HomeStatsState> emit) {
    return _refreshStats(emit);
  }

  Future<void> _refreshStats(Emitter<HomeStatsState> emit) async {
    if (state.isRefreshing) {
      return;
    }

    emit(state.copyWith(isRefreshing: true, clearError: true));

    try {
      final snapshot = await _streaksRepository.getGlobalSnapshot(nowLocal: _nowLocal());
      emit(
        state.copyWith(
          isRefreshing: false,
          streakDays: snapshot.currentStreakDays.value,
          focusedDuration: snapshot.todayEffectiveDuration,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(isRefreshing: false, error: error));
    }
  }

  @override
  Future<void> close() async {
    await _lifecycleActionsSubscription.cancel();
    await super.close();
  }
}
