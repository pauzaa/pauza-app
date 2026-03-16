import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_entry_dto.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_rank_dto.dart';
import 'package:pauza/src/features/leaderboard/data/leaderboard_repository.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc({
    required LeaderboardRepository leaderboardRepository,
  })  : _leaderboardRepository = leaderboardRepository,
        super(const LeaderboardState.initial()) {
    on<LeaderboardLoadRequested>(_onLoadRequested);
    on<LeaderboardTabChanged>(_onTabChanged);
  }

  final LeaderboardRepository _leaderboardRepository;

  Future<void> _onLoadRequested(
    LeaderboardLoadRequested event,
    Emitter<LeaderboardState> emit,
  ) {
    return _fetch(emit);
  }

  Future<void> _onTabChanged(
    LeaderboardTabChanged event,
    Emitter<LeaderboardState> emit,
  ) {
    emit(
      state.copyWith(
        tab: event.tab,
        entries: const <LeaderboardEntryDto>[],
        clearError: true,
      ),
    );
    return _fetch(emit);
  }

  Future<void> _fetch(Emitter<LeaderboardState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final dto = switch (state.tab) {
        LeaderboardTab.currentStreak =>
          await _leaderboardRepository.fetchStreakLeaderboard(),
        LeaderboardTab.totalFocus =>
          await _leaderboardRepository.fetchFocusTimeLeaderboard(),
      };

      emit(
        state.copyWith(
          isLoading: false,
          entries: dto.entries,
          myRank: dto.myRank,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    }
  }
}
