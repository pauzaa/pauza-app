import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/friends/common/model/friend_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_stats_dto.dart';
import 'package:pauza/src/features/friends/data/friends_repository.dart';

part 'friends_list_event.dart';
part 'friends_list_state.dart';

class FriendsListBloc extends Bloc<FriendsListEvent, FriendsListState> {
  FriendsListBloc({required FriendsRepository friendsRepository})
    : _friendsRepository = friendsRepository,
      super(const FriendsListState.initial()) {
    on<FriendsListLoadRequested>(_onLoadRequested);
    on<FriendsListSearchChanged>(_onSearchChanged);
    on<FriendsListRefreshRequested>(_onRefreshRequested);
  }

  final FriendsRepository _friendsRepository;

  Future<void> _onLoadRequested(FriendsListLoadRequested event, Emitter<FriendsListState> emit) {
    return _fetch(emit);
  }

  void _onSearchChanged(FriendsListSearchChanged event, Emitter<FriendsListState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _onRefreshRequested(FriendsListRefreshRequested event, Emitter<FriendsListState> emit) {
    return _fetch(emit);
  }

  Future<void> _fetch(Emitter<FriendsListState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final result = await _friendsRepository.fetchFriends(page: 1, limit: 100);
      final friends = result.friends;

      emit(state.copyWith(isLoading: false, friends: friends, clearError: true));

      final statsMap = <String, FriendStatsDto>{};
      for (final friend in friends) {
        try {
          final stats = await _friendsRepository.fetchFriendStats(friendshipId: friend.friendshipId, days: 7);
          statsMap[friend.friendshipId] = stats;
        } on Object {
          // Skip stats for this friend if fetch fails
        }
      }

      if (statsMap.isNotEmpty) {
        emit(state.copyWith(friendStats: statsMap));
      }
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    }
  }
}
