import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';

part 'current_user_event.dart';

/// Session-driven profile state manager.
///
/// Auth session is the source of truth. This bloc only derives profile UI state
/// from auth session and profile repository operations.
class CurrentUserBloc extends Bloc<CurrentUserEvent, CurrentUserState> {
  CurrentUserBloc({required AuthRepository authRepository, required UserProfileRepository userProfileRepository})
    : _authRepository = authRepository,
      _userProfileRepository = userProfileRepository,
      super(const CurrentUserState.unauthenticated()) {
    _sessionSubscription = _authRepository.sessionStream.listen((session) {
      add(CurrentUserSessionChanged(session: session));
    });
    _profileChangesSubscription = _userProfileRepository.watchProfileChanges().listen((user) {
      add(CurrentUserProfileUpdatedFromRepository(user: user));
    });
    on<CurrentUserSessionChanged>(_onSessionChanged);
    on<CurrentUserProfileUpdatedFromRepository>(_onProfileUpdatedFromRepository);
    on<CurrentUserRefreshRequested>(_onRefreshRequested, transformer: droppable());
  }

  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;

  StreamSubscription<Session>? _sessionSubscription;
  StreamSubscription<UserDto>? _profileChangesSubscription;

  /// Public trigger for user-initiated refresh actions.
  void refresh({bool forceRemote = false}) {
    add(CurrentUserRefreshRequested(forceRemote: forceRemote));
  }

  Future<void> _onSessionChanged(CurrentUserSessionChanged event, Emitter<CurrentUserState> emit) async {
    final session = event.session;
    if (!session.isAuthenticated) {
      _emit(emit, const CurrentUserState.unauthenticated());
      return;
    }

    _emit(emit, const CurrentUserState.loading());
    add(const CurrentUserRefreshRequested(forceRemote: true));
  }

  Future<void> _onRefreshRequested(CurrentUserRefreshRequested event, Emitter<CurrentUserState> emit) async {
    final session = _authRepository.currentSession;
    if (!session.isAuthenticated) {
      _emit(emit, const CurrentUserState.unauthenticated());
      return;
    }

    try {
      final user = await _userProfileRepository.fetchProfile(forceRemote: event.forceRemote);
      _emit(emit, CurrentUserState.available(user: user));
    } on UserProfileError catch (error) {
      await _handleRefreshFailure(error: error, previous: state, emit: emit);
    } on Object catch (e) {
      await _handleRefreshFailure(error: UserProfileUnknownError(e), previous: state, emit: emit);
    }
  }

  void _onProfileUpdatedFromRepository(CurrentUserProfileUpdatedFromRepository event, Emitter<CurrentUserState> emit) {
    final session = _authRepository.currentSession;
    if (!session.isAuthenticated) return;
    _emit(emit, CurrentUserState.available(user: event.user));
  }

  Future<void> _handleRefreshFailure({
    required UserProfileError error,
    required CurrentUserState previous,
    required Emitter<CurrentUserState> emit,
  }) async {
    switch (error) {
      case UserProfileUnauthorizedError():
      case UserProfileForbiddenError():
        await _authRepository.signOut();
        return;
      case UserProfileNetworkError():
        if (previous.status == CurrentUserStatus.available) {
          // Keep showing the existing profile.
          return;
        }
        _emit(emit, const CurrentUserState.unavailable(error: UserProfileNetworkError()));
        return;
      case UserProfileStorageError():
      case UserProfileUsernameTakenError():
      case UserProfileValidationError():
      case UserProfileCancelledError():
      case UserProfileUnknownError():
        if (previous.status == CurrentUserStatus.available) {
          return;
        }
        String? message;
        if (error is UserProfileStorageError) {
          message = error.cause?.toString();
        } else if (error is UserProfileUnknownError) {
          message = error.cause?.toString();
        }
        _emit(emit, CurrentUserState.error(error: error, message: message));
        return;
    }
  }

  void _emit(Emitter<CurrentUserState> emit, CurrentUserState next) {
    if (state == next || isClosed) return;
    emit(next);
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    await _profileChangesSubscription?.cancel();
    return super.close();
  }
}
