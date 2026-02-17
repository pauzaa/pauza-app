import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/auth/common/model/auth_credentials_dto.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';

void main() {
  group('CurrentUserBloc', () {
    test(
      'authenticated startup with fresh cache emits cache then fresh user',
      () async {
        final authRepository = _FakeAuthRepository(
          initialSession: const Session(accessToken: 'a', refreshToken: 'b'),
        );
        final repository = _FakeUserProfileRepository(
          cachedProfile: CachedUserProfile(
            user: const UserDto(
              profilePicture: 'https://example.com/avatar/john.png',
              username: 'john',
              name: 'John',
            ),
            cachedAtUtc: DateTime.utc(2026, 2, 16, 10),
          ),
          remoteUser: const UserDto(
            profilePicture: 'https://example.com/avatar/john.png',
            username: 'john',
            name: 'John',
          ),
        );
        final bloc = CurrentUserBloc(
          authRepository: authRepository,
          userProfileRepository: repository,
          ttl: const Duration(minutes: 15),
          nowUtc: () => DateTime.utc(2026, 2, 16, 10, 5),
        );
        final states = <CurrentUserState>[];
        final subscription = bloc.stream.listen(states.add);

        await _flushAsync();

        expect(states.first.status, CurrentUserStatus.available);
        expect(states.first.isSyncing, isTrue);
        expect(bloc.state.status, CurrentUserStatus.available);
        expect(bloc.state.freshness, UserFreshness.fresh);
        expect(bloc.state.isSyncing, isFalse);

        await subscription.cancel();
        await bloc.close();
        authRepository.dispose();
      },
    );

    test(
      'startup with stale cache then remote success updates fresh state',
      () async {
        final authRepository = _FakeAuthRepository(
          initialSession: const Session(accessToken: 'a', refreshToken: 'b'),
        );
        final repository = _FakeUserProfileRepository(
          cachedProfile: CachedUserProfile(
            user: const UserDto(
              profilePicture: 'https://example.com/avatar/jane.png',
              username: 'jane',
              name: 'Jane',
            ),
            cachedAtUtc: DateTime.utc(2026, 2, 16, 8),
          ),
          remoteUser: const UserDto(
            profilePicture: 'https://example.com/avatar/jane.png',
            username: 'jane',
            name: 'Jane',
          ),
        );
        final bloc = CurrentUserBloc(
          authRepository: authRepository,
          userProfileRepository: repository,
          ttl: const Duration(minutes: 15),
          nowUtc: () => DateTime.utc(2026, 2, 16, 10),
        );

        await _flushAsync();

        expect(bloc.state.status, CurrentUserStatus.available);
        expect(bloc.state.freshness, UserFreshness.fresh);
        expect(bloc.state.isSyncing, isFalse);

        await bloc.close();
        authRepository.dispose();
      },
    );

    test(
      'offline with cache keeps cached user and does not sign out',
      () async {
        final authRepository = _FakeAuthRepository(
          initialSession: const Session(accessToken: 'a', refreshToken: 'b'),
        );
        final repository = _FakeUserProfileRepository(
          cachedProfile: CachedUserProfile(
            user: const UserDto(
              profilePicture: 'https://example.com/avatar/jane.png',
              username: 'jane',
              name: 'Jane',
            ),
            cachedAtUtc: DateTime.utc(2026, 2, 16, 8),
          ),
          remoteError: const UserProfileException(
            code: UserProfileFailureCode.network,
          ),
        );
        final bloc = CurrentUserBloc(
          authRepository: authRepository,
          userProfileRepository: repository,
          ttl: const Duration(minutes: 15),
          nowUtc: () => DateTime.utc(2026, 2, 16, 10),
        );

        await _flushAsync();

        expect(bloc.state.status, CurrentUserStatus.available);
        expect(bloc.state.isSyncing, isFalse);
        expect(authRepository.signOutCallCount, 0);

        await bloc.close();
        authRepository.dispose();
      },
    );

    test(
      'offline with no cache emits unavailable and preserves session',
      () async {
        final authRepository = _FakeAuthRepository(
          initialSession: const Session(accessToken: 'a', refreshToken: 'b'),
        );
        final repository = _FakeUserProfileRepository(
          remoteError: const UserProfileException(
            code: UserProfileFailureCode.network,
          ),
        );
        final bloc = CurrentUserBloc(
          authRepository: authRepository,
          userProfileRepository: repository,
          ttl: const Duration(minutes: 15),
          nowUtc: () => DateTime.utc(2026, 2, 16, 10),
        );

        await _flushAsync();

        expect(bloc.state.status, CurrentUserStatus.unavailable);
        expect(authRepository.currentSession.isAuthenticated, isTrue);
        expect(authRepository.signOutCallCount, 0);

        await bloc.close();
        authRepository.dispose();
      },
    );

    test('401 and 403 trigger sign out', () async {
      for (final error in <UserProfileException>[
        const UserProfileException(code: UserProfileFailureCode.unauthorized),
        const UserProfileException(code: UserProfileFailureCode.forbidden),
      ]) {
        final authRepository = _FakeAuthRepository(
          initialSession: const Session(accessToken: 'a', refreshToken: 'b'),
        );
        final repository = _FakeUserProfileRepository(remoteError: error);
        final bloc = CurrentUserBloc(
          authRepository: authRepository,
          userProfileRepository: repository,
          ttl: const Duration(minutes: 15),
          nowUtc: () => DateTime.utc(2026, 2, 16, 10),
        );

        await _flushAsync();

        expect(authRepository.signOutCallCount, 1);
        expect(bloc.state.status, CurrentUserStatus.unauthenticated);

        await bloc.close();
        authRepository.dispose();
      }
    });

    test('session clear emits unauthenticated and clears cache', () async {
      final authRepository = _FakeAuthRepository(
        initialSession: const Session(accessToken: 'a', refreshToken: 'b'),
      );
      final repository = _FakeUserProfileRepository(
        cachedProfile: CachedUserProfile(
          user: const UserDto(
            profilePicture: 'https://example.com/avatar/john.png',
            username: 'john',
            name: 'John',
          ),
          cachedAtUtc: DateTime.utc(2026, 2, 16, 10),
        ),
        remoteUser: const UserDto(
          profilePicture: 'https://example.com/avatar/john.png',
          username: 'john',
          name: 'John',
        ),
      );
      final bloc = CurrentUserBloc(
        authRepository: authRepository,
        userProfileRepository: repository,
        ttl: const Duration(minutes: 15),
        nowUtc: () => DateTime.utc(2026, 2, 16, 10, 2),
      );

      await _flushAsync();

      authRepository.emitSession(const Session.empty());
      await _flushAsync();

      expect(bloc.state.status, CurrentUserStatus.unauthenticated);
      expect(repository.clearCacheCallCount, greaterThan(0));

      await bloc.close();
      authRepository.dispose();
    });
  });
}

Future<void> _flushAsync() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required Session initialSession})
    : _currentSession = initialSession;

  final StreamController<Session> _controller =
      StreamController<Session>.broadcast();

  Session _currentSession;
  int signOutCallCount = 0;

  @override
  Session get currentSession => _currentSession;

  @override
  Stream<Session> get sessionStream async* {
    yield _currentSession;
    yield* _controller.stream;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<AuthResult> signIn(AuthCredentialsDto credentials) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> verifyOtp({required String otp}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
    _currentSession = const Session.empty();
    _controller.add(_currentSession);
  }

  @override
  Future<void> clearPendingOtpChallenge() async {}

  void emitSession(Session session) {
    _currentSession = session;
    _controller.add(session);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

final class _FakeUserProfileRepository implements UserProfileRepository {
  _FakeUserProfileRepository({
    this.cachedProfile,
    this.remoteUser,
    this.remoteError,
  });

  CachedUserProfile? cachedProfile;
  UserDto? remoteUser;
  UserProfileException? remoteError;
  int clearCacheCallCount = 0;

  @override
  Future<void> clearCache() async {
    clearCacheCallCount += 1;
    cachedProfile = null;
  }

  @override
  Future<UserDto> fetchAndCacheProfile({required Session session}) async {
    if (remoteError case final error?) {
      throw error;
    }
    final user = remoteUser;
    if (user == null) {
      throw const UserProfileException(code: UserProfileFailureCode.unknown);
    }

    cachedProfile = CachedUserProfile(
      user: user,
      cachedAtUtc: DateTime.utc(2026, 2, 16, 10),
    );
    return user;
  }

  @override
  Future<CachedUserProfile?> readCachedProfile() async {
    return cachedProfile;
  }
}
