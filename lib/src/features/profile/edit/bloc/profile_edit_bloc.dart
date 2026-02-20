import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';

part 'profile_edit_event.dart';
part 'profile_edit_state.dart';

final class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  ProfileEditBloc({required UserProfileRepository userProfileRepository})
    : _userProfileRepository = userProfileRepository,
      super(const ProfileEditInitial()) {
    on<ProfileEditStarted>(_onStarted);
    on<ProfileEditSaveRequested>(_onSaveRequested);
  }

  final UserProfileRepository _userProfileRepository;

  Future<void> _onStarted(
    ProfileEditStarted event,
    Emitter<ProfileEditState> emit,
  ) async {
    emit(state.loading());

    try {
      final cached = await _userProfileRepository.readCachedProfile();
      final user =
          cached?.user ?? await _userProfileRepository.fetchAndCacheProfile();
      emit(state.ready(user));
    } on UserProfileException catch (error) {
      emit(state.failure(error.code, error.message));
    } on Object catch (error) {
      emit(state.failure(UserProfileFailureCode.unknown, error.toString()));
    }
  }

  Future<void> _onSaveRequested(
    ProfileEditSaveRequested event,
    Emitter<ProfileEditState> emit,
  ) async {
    if (!state.isReady) {
      return;
    }

    if (state.isSaving) {
      return;
    }

    emit(state.saving());

    try {
      await _userProfileRepository.updateProfile(
        name: event.name,
        username: event.username,
        profilePictureUrl: event.profilePictureUrl,
        profilePictureBytes: event.profilePictureBytes,
      );
      emit(state.success());
    } on UserProfileException catch (error) {
      emit(state.failure(error.code, error.message));
    } on Object catch (error) {
      emit(state.failure(UserProfileFailureCode.unknown, error.toString()));
    }
  }
}
