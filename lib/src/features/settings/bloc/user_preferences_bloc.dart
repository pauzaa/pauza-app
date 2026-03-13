import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';

part 'user_preferences_event.dart';
part 'user_preferences_state.dart';

final class UserPreferencesBloc
    extends Bloc<UserPreferencesEvent, UserPreferencesState> {
  UserPreferencesBloc({
    required UserProfileRepository userProfileRepository,
  }) : _userProfileRepository = userProfileRepository,
       super(const UserPreferencesState()) {
    on<UserPreferencesStarted>(_onStarted);
    on<UserPreferencesPushToggled>(_onPushToggled);
    on<UserPreferencesLeaderboardToggled>(_onLeaderboardToggled);
  }

  final UserProfileRepository _userProfileRepository;

  Future<void> _onStarted(
    UserPreferencesStarted event,
    Emitter<UserPreferencesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final cached = await _userProfileRepository.readCachedProfile();
      if (cached != null) {
        emit(state.copyWith(
          isLoading: false,
          pushEnabled: cached.user.pushEnabled,
          leaderboardVisible: cached.user.leaderboardVisible,
        ));
        return;
      }

      final profile = await _userProfileRepository.fetchAndCacheProfile();
      emit(state.copyWith(
        isLoading: false,
        pushEnabled: profile.pushEnabled,
        leaderboardVisible: profile.leaderboardVisible,
      ));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    }
  }

  Future<void> _onPushToggled(
    UserPreferencesPushToggled event,
    Emitter<UserPreferencesState> emit,
  ) async {
    final previous = state.pushEnabled;
    emit(state.copyWith(
      pushEnabled: event.enabled,
      isSavingPush: true,
      clearError: true,
    ));

    try {
      final result = await _userProfileRepository.updateNotificationPreferences(
        pushEnabled: event.enabled,
      );
      emit(state.copyWith(pushEnabled: result, isSavingPush: false));
    } on Object catch (error) {
      emit(state.copyWith(
        pushEnabled: previous,
        isSavingPush: false,
        error: error,
      ));
    }
  }

  Future<void> _onLeaderboardToggled(
    UserPreferencesLeaderboardToggled event,
    Emitter<UserPreferencesState> emit,
  ) async {
    final previous = state.leaderboardVisible;
    emit(state.copyWith(
      leaderboardVisible: event.visible,
      isSavingLeaderboard: true,
      clearError: true,
    ));

    try {
      final result = await _userProfileRepository.updatePrivacyPreferences(
        leaderboardVisible: event.visible,
      );
      emit(state.copyWith(
        leaderboardVisible: result,
        isSavingLeaderboard: false,
      ));
    } on Object catch (error) {
      emit(state.copyWith(
        leaderboardVisible: previous,
        isSavingLeaderboard: false,
        error: error,
      ));
    }
  }
}
