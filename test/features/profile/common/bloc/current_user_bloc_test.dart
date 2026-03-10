import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';

void main() {
  const authenticatedSession = Session(accessToken: 'access', refreshToken: 'refresh');
  const user = UserDto(profilePicture: null, username: 'john', name: 'John');

  test('signs out and transitions to unauthenticated on unauthorized profile refresh', () async {
    final authRepository = _FakeAuthRepository(currentSession: authenticatedSession);
    final profileRepository = _FakeUserProfileRepository(fetchAndCacheError: const UserProfileUnauthorizedError());
    final bloc = CurrentUserBloc(
      authRepository: authRepository,
      userProfileRepository: profileRepository,
      ttl: const Duration(minutes: 5),
      nowUtc: () => DateTime.utc(2026, 2, 27),
    );

    bloc.add(const CurrentUserSessionChanged(session: authenticatedSession));
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(authRepository.signOutCalls, 1);
    expect(bloc.state, const CurrentUserState.unauthenticated());

    await bloc.close();
    authRepository.dispose();
  });

  test('emits unavailable state with Object error for network failures without cached profile', () async {
    final authRepository = _FakeAuthRepository(currentSession: authenticatedSession);
    final profileRepository = _FakeUserProfileRepository(fetchAndCacheError: const UserProfileNetworkError());
    final bloc = CurrentUserBloc(
      authRepository: authRepository,
      userProfileRepository: profileRepository,
      ttl: const Duration(minutes: 5),
      nowUtc: () => DateTime.utc(2026, 2, 27),
    );

    bloc.add(const CurrentUserRefreshRequested(forceRemote: true));
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(bloc.state.status, CurrentUserStatus.unavailable);
    expect(bloc.state.error, isA<UserProfileNetworkError>());

    await bloc.close();
    authRepository.dispose();
  });

  test('emits error state with unknown Object error and message for unknown failures', () async {
    final authRepository = _FakeAuthRepository(currentSession: authenticatedSession);
    final profileRepository = _FakeUserProfileRepository(
      fetchAndCacheError: UserProfileUnknownError(Exception('boom')),
    );
    final bloc = CurrentUserBloc(
      authRepository: authRepository,
      userProfileRepository: profileRepository,
      ttl: const Duration(minutes: 5),
      nowUtc: () => DateTime.utc(2026, 2, 27),
    );

    bloc.add(const CurrentUserRefreshRequested(forceRemote: true));
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(bloc.state.status, CurrentUserStatus.error);
    expect(bloc.state.error, isA<UserProfileUnknownError>());
    expect(bloc.state.message, contains('boom'));

    await bloc.close();
    authRepository.dispose();
  });

  test('keeps available state when refresh fails with network error after cached profile', () async {
    final authRepository = _FakeAuthRepository(currentSession: authenticatedSession);
    final profileRepository = _FakeUserProfileRepository(
      readCachedProfileResult: CachedUserProfile(user: user, cachedAtUtc: DateTime.utc(2026, 2, 27)),
      fetchAndCacheError: const UserProfileNetworkError(),
    );
    final bloc = CurrentUserBloc(
      authRepository: authRepository,
      userProfileRepository: profileRepository,
      ttl: const Duration(minutes: 5),
      nowUtc: () => DateTime.utc(2026, 2, 27),
    );

    bloc.add(const CurrentUserSessionChanged(session: authenticatedSession));
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(bloc.state.status, CurrentUserStatus.available);
    expect(bloc.state.isSyncing, isFalse);
    expect(bloc.state.user, user);
    expect(bloc.state.error, isNull);

    await bloc.close();
    authRepository.dispose();
  });
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required Session currentSession}) : _currentSession = currentSession;

  final StreamController<Session> _sessionController = StreamController<Session>.broadcast();
  Session _currentSession;
  int signOutCalls = 0;

  @override
  Session get currentSession => _currentSession;

  @override
  Stream<Session> get sessionStream => _sessionController.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<AuthOtpRequiredResult> requestOtp({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<AuthOtpRequiredResult> resendOtp({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> verifyOtp({required String otp}) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearPendingOtpChallenge() async {}

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    _currentSession = const Session.empty();
    _sessionController.add(_currentSession);
  }

  @override
  void dispose() {
    _sessionController.close();
  }
}

final class _FakeUserProfileRepository implements UserProfileRepository {
  _FakeUserProfileRepository({this.readCachedProfileResult, this.fetchAndCacheError});

  final CachedUserProfile? readCachedProfileResult;
  final Object? fetchAndCacheError;

  @override
  Future<CachedUserProfile?> readCachedProfile() async => readCachedProfileResult;

  @override
  Future<UserDto> fetchAndCacheProfile() async {
    if (fetchAndCacheError case final error?) {
      throw error;
    }
    return const UserDto(profilePicture: null, username: 'john', name: 'John');
  }

  @override
  Future<UserDto> updateProfile({
    required String name,
    required String username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isUsernameAvailable({required String username}) {
    throw UnimplementedError();
  }

  @override
  Future<String> uploadProfilePhoto({required String localFilePath}) {
    throw UnimplementedError();
  }

  @override
  Stream<UserDto> watchProfileChanges() => const Stream<UserDto>.empty();

  @override
  Future<void> clearCache() async {}
}
