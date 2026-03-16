import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_request_dto.dart';
import 'package:pauza/src/features/friends/data/friends_repository.dart';

part 'find_and_requests_event.dart';
part 'find_and_requests_state.dart';

class FindAndRequestsBloc extends Bloc<FindAndRequestsEvent, FindAndRequestsState> {
  FindAndRequestsBloc({required FriendsRepository friendsRepository})
    : _friendsRepository = friendsRepository,
      super(const FindAndRequestsState.initial()) {
    on<FindAndRequestsLoadRequested>(_onLoadRequested);
    on<FindAndRequestsSearchChanged>(_onSearchChanged, transformer: restartable());
    on<FindAndRequestsAccepted>(_onAccepted);
    on<FindAndRequestsDeclined>(_onDeclined);
    on<FindAndRequestsCancelled>(_onCancelled);
    on<FindAndRequestsSendRequest>(_onSendRequest);
  }

  final FriendsRepository _friendsRepository;

  Future<void> _onLoadRequested(FindAndRequestsLoadRequested event, Emitter<FindAndRequestsState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final (incoming, outgoing) = await (
        _friendsRepository.fetchIncomingRequests(),
        _friendsRepository.fetchOutgoingRequests(),
      ).wait;

      emit(state.copyWith(isLoading: false, incomingRequests: incoming, outgoingRequests: outgoing, clearError: true));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    }
  }

  Future<void> _onSearchChanged(FindAndRequestsSearchChanged event, Emitter<FindAndRequestsState> emit) async {
    final query = event.query.trim();
    emit(state.copyWith(searchQuery: query));

    if (query.isEmpty) {
      emit(state.copyWith(searchResults: const <BasicUserDto>[], isSearching: false));
      return;
    }

    emit(state.copyWith(isSearching: true));

    try {
      final results = await _friendsRepository.searchUsers(query: query);
      emit(state.copyWith(searchResults: results, isSearching: false));
    } on Object catch (error) {
      emit(state.copyWith(isSearching: false, error: error));
    }
  }

  Future<void> _onAccepted(FindAndRequestsAccepted event, Emitter<FindAndRequestsState> emit) async {
    emit(state.copyWith(actionInProgress: {...state.actionInProgress, event.friendshipId}));

    try {
      await _friendsRepository.acceptRequest(friendshipId: event.friendshipId);
      emit(
        state.copyWith(
          incomingRequests: state.incomingRequests.where((r) => r.friendshipId != event.friendshipId).toList(),
          actionInProgress: state.actionInProgress.difference({event.friendshipId}),
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(actionInProgress: state.actionInProgress.difference({event.friendshipId}), error: error));
    }
  }

  Future<void> _onDeclined(FindAndRequestsDeclined event, Emitter<FindAndRequestsState> emit) async {
    emit(state.copyWith(actionInProgress: {...state.actionInProgress, event.friendshipId}));

    try {
      await _friendsRepository.declineRequest(friendshipId: event.friendshipId);
      emit(
        state.copyWith(
          incomingRequests: state.incomingRequests.where((r) => r.friendshipId != event.friendshipId).toList(),
          actionInProgress: state.actionInProgress.difference({event.friendshipId}),
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(actionInProgress: state.actionInProgress.difference({event.friendshipId}), error: error));
    }
  }

  Future<void> _onCancelled(FindAndRequestsCancelled event, Emitter<FindAndRequestsState> emit) async {
    emit(state.copyWith(actionInProgress: {...state.actionInProgress, event.friendshipId}));

    try {
      await _friendsRepository.cancelRequest(friendshipId: event.friendshipId);
      emit(
        state.copyWith(
          outgoingRequests: state.outgoingRequests.where((r) => r.friendshipId != event.friendshipId).toList(),
          actionInProgress: state.actionInProgress.difference({event.friendshipId}),
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(actionInProgress: state.actionInProgress.difference({event.friendshipId}), error: error));
    }
  }

  Future<void> _onSendRequest(FindAndRequestsSendRequest event, Emitter<FindAndRequestsState> emit) async {
    emit(state.copyWith(actionInProgress: {...state.actionInProgress, event.username}));

    try {
      final mutation = await _friendsRepository.sendRequest(username: event.username);
      final newRequest = FriendRequestDto(
        friendshipId: mutation.friendshipId,
        user: state.searchResults.firstWhere(
          (u) => u.username == event.username,
          orElse: () => BasicUserDto(id: '', name: event.username, username: event.username),
        ),
        createdAt: DateTime.now().toUtc(),
      );
      emit(
        state.copyWith(
          outgoingRequests: [...state.outgoingRequests, newRequest],
          actionInProgress: state.actionInProgress.difference({event.username}),
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(actionInProgress: state.actionInProgress.difference({event.username}), error: error));
    }
  }
}
