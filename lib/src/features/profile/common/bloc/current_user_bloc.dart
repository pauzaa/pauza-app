import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';

part 'current_user_event.dart';

/// Session-driven profile state manager.
///
/// Auth session is the source of truth. This bloc only derives profile UI state
/// from auth session and profile repository operations.
final class CurrentUserBloc extends Bloc<CurrentUserEvent, CurrentUserState> {
  CurrentUserBloc({
    required AuthRepository authRepository,
    required UserProfileRepository userProfileRepository,
    required Duration ttl,
    required DateTime Function() nowUtc,
  }) : _authRepository = authRepository,
       _userProfileRepository = userProfileRepository,
       _ttl = ttl,
       _nowUtc = nowUtc,
       super(const CurrentUserState.unauthenticated()) {
    // Subscribe first, then react through events so all transitions stay in one place.
    _sessionSubscription = _authRepository.sessionStream.listen((session) {
      add(CurrentUserSessionChanged(session: session));
    });
    _profileChangesSubscription = _userProfileRepository.watchProfileChanges().listen((user) {
      add(CurrentUserProfileUpdatedFromRepository(user: user));
    });
    on<CurrentUserSessionChanged>(_onSessionChanged);
    on<CurrentUserProfileUpdatedFromRepository>(_onProfileUpdatedFromRepository);
    // Prevent overlapping refreshes; latest duplicate refresh intent is dropped while one runs.
    on<CurrentUserRefreshRequested>(_onRefreshRequested, transformer: droppable());
  }

  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;
  final Duration _ttl;
  final DateTime Function() _nowUtc;

  StreamSubscription<Session>? _sessionSubscription;
  StreamSubscription<UserDto>? _profileChangesSubscription;

  /// Public trigger for user-initiated refresh actions.
  void refresh({bool forceRemote = false}) {
    add(CurrentUserRefreshRequested(forceRemote: forceRemote));
  }

  Future<void> _onSessionChanged(CurrentUserSessionChanged event, Emitter<CurrentUserState> emit) async {
    final session = event.session;
    if (!session.isAuthenticated) {
      // Keep profile cache scoped to active auth session.
      await _clearCacheIgnoringErrors();
      _emit(emit, const CurrentUserState.unauthenticated());
      return;
    }

    CachedUserProfile? cached;
    try {
      cached = await _userProfileRepository.readCachedProfile();
    } on UserProfileStorageError {
      await _clearCacheIgnoringErrors();
    } on Object {
      await _clearCacheIgnoringErrors();
    }

    if (cached != null) {
      // Show cached profile immediately for fast UI, then sync in background.
      final nowUtc = _nowUtc();
      final freshness = cached.isFresh(nowUtc: nowUtc, ttl: _ttl) ? UserFreshness.fresh : UserFreshness.stale;
      _emit(
        emit,
        CurrentUserState.available(
          user: cached.user,
          freshness: freshness,
          cachedAtUtc: cached.cachedAtUtc,
          isSyncing: true,
        ),
      );
    } else {
      _emit(emit, const CurrentUserState.loading());
    }

    // Always attempt remote sync when a valid session is present.
    add(const CurrentUserRefreshRequested(forceRemote: true));
  }

  Future<void> _onRefreshRequested(CurrentUserRefreshRequested event, Emitter<CurrentUserState> emit) async {
    final session = _authRepository.currentSession;
    if (!session.isAuthenticated) {
      _emit(emit, const CurrentUserState.unauthenticated());
      return;
    }

    if (!event.forceRemote) {
      // Skip redundant refresh if we already have a non-syncing fresh profile.
      if (state.status == CurrentUserStatus.available && state.freshness == UserFreshness.fresh && !state.isSyncing) {
        return;
      }
    }

    final previous = state;
    if (previous.status == CurrentUserStatus.available && !previous.isSyncing) {
      // Preserve visible profile while showing in-flight sync indicator.
      _emit(emit, previous.copyWith(isSyncing: true, clearError: true, clearMessage: true));
    }

    try {
      final user = await _userProfileRepository.fetchAndCacheProfile();
      _emit(
        emit,
        CurrentUserState.available(
          user: user,
          freshness: UserFreshness.fresh,
          cachedAtUtc: _nowUtc(),
          isSyncing: false,
        ),
      );
    } on UserProfileError catch (error) {
      await _handleRefreshFailure(error: error, previous: previous, emit: emit);
    } on Object catch (e) {
      await _handleRefreshFailure(error: UserProfileUnknownError(e), previous: previous, emit: emit);
    }
  }

  void _onProfileUpdatedFromRepository(CurrentUserProfileUpdatedFromRepository event, Emitter<CurrentUserState> emit) {
    final session = _authRepository.currentSession;
    if (!session.isAuthenticated) {
      return;
    }

    _emit(
      emit,
      CurrentUserState.available(
        user: event.user,
        freshness: UserFreshness.fresh,
        cachedAtUtc: _nowUtc(),
        isSyncing: false,
      ),
    );
  }

  Future<void> _handleRefreshFailure({
    required UserProfileError error,
    required CurrentUserState previous,
    required Emitter<CurrentUserState> emit,
  }) async {
    switch (error) {
      case UserProfileUnauthorizedError():
      case UserProfileForbiddenError():
        // Profile endpoint rejected session; enforce auth reset centrally.
        await _authRepository.signOut();
        return;
      case UserProfileNetworkError():
        if (previous.status == CurrentUserStatus.available) {
          _emit(emit, previous.copyWith(isSyncing: false));
        } else {
          _emit(emit, const CurrentUserState.unavailable(error: UserProfileNetworkError()));
        }
        return;
      case UserProfileStorageError():
      case UserProfileUsernameTakenError():
      case UserProfileValidationError():
      case UserProfileCancelledError():
      case UserProfileUnknownError():
        if (previous.status == CurrentUserStatus.available) {
          _emit(emit, previous.copyWith(isSyncing: false));
        } else {
          String? message;
          if (error is UserProfileStorageError) {
            message = error.cause?.toString();
          } else if (error is UserProfileUnknownError) {
            message = error.cause?.toString();
          }
          _emit(emit, CurrentUserState.error(error: error, message: message));
        }
        return;
    }
  }

  Future<void> _clearCacheIgnoringErrors() async {
    try {
      await _userProfileRepository.clearCache();
    } on Object {
      // Cache cleanup must not block auth/session state transitions.
    }
  }

  void _emit(Emitter<CurrentUserState> emit, CurrentUserState next) {
    if (state == next || isClosed) {
      return;
    }
    emit(next);
  }

  @override
  Future<void> close() async {
    // Avoid leaked subscriptions after scope disposal.
    await _sessionSubscription?.cancel();
    await _profileChangesSubscription?.cancel();
    return super.close();
  }
}
