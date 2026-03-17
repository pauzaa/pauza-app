import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/model/pauza_app_error.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';

part 'profile_edit_event.dart';
part 'profile_edit_state.dart';

final class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  ProfileEditBloc({
    required UserProfileRepository userProfileRepository,
    required InternetRequiredGuard internetRequiredGuard,
  }) : _userProfileRepository = userProfileRepository,
       _internetRequiredGuard = internetRequiredGuard,
       super(const ProfileEditInitial()) {
    on<ProfileEditStarted>(_onStarted);
    on<ProfileEditSaveRequested>(_onSaveRequested);
  }

  final UserProfileRepository _userProfileRepository;
  final InternetRequiredGuard _internetRequiredGuard;

  Future<void> _onStarted(ProfileEditStarted event, Emitter<ProfileEditState> emit) async {
    emit(state.loading());

    try {
      final user = await _userProfileRepository.fetchProfile();
      emit(state.ready(user));
    } on Object catch (error) {
      emit(state.failure(error));
    }
  }

  Future<void> _onSaveRequested(ProfileEditSaveRequested event, Emitter<ProfileEditState> emit) async {
    if (!state.isReady) {
      return;
    }

    if (state.isSaving) {
      return;
    }

    emit(state.saving());

    final canProceed = await _internetRequiredGuard.canProceed();
    if (!canProceed) {
      emit(state.failure(const PauzaInternetUnavailableError()));
      return;
    }

    try {
      await _userProfileRepository.updateProfile(
        name: event.name,
        username: event.username,
        profilePictureUrl: event.profilePictureUrl,
        profilePictureBytes: event.profilePictureBytes,
      );
      emit(state.success());
    } on Object catch (error) {
      emit(state.failure(error));
    }
  }
}
