import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/auth/common/model/auth_credentials_dto.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/common/model/user_dto.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';

void main() {
  group('AuthBloc', () {
    test('startup with empty session leads to AuthUnauthenticated', () async {
      final repository = _FakeAuthRepository(
        initialSession: const Session.empty(),
      );
      final bloc = AuthBloc(authRepository: repository);

      bloc.add(const AuthStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthUnauthenticated>());

      await bloc.close();
      repository.dispose();
    });

    test('successful sign in emits AuthAuthenticated', () async {
      final repository = _FakeAuthRepository();
      final bloc = AuthBloc(authRepository: repository);

      bloc.add(
        const AuthSignInRequested(email: 'john@doe.com', password: '123456'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthAuthenticated>());

      await bloc.close();
      repository.dispose();
    });

    test(
      'wrong credentials emit AuthFailureState invalidCredentials',
      () async {
        final repository = _FakeAuthRepository();
        final bloc = AuthBloc(authRepository: repository);

        bloc.add(
          const AuthSignInRequested(
            email: AuthRepositoryImpl.invalidCredentialsEmail,
            password: '123456',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(bloc.state, isA<AuthFailureState>());
        expect(
          (bloc.state as AuthFailureState).failure,
          AuthFailure.invalidCredentials,
        );

        await bloc.close();
        repository.dispose();
      },
    );

    test('unknown email flow emits AuthOtpRequired', () async {
      final repository = _FakeAuthRepository();
      final bloc = AuthBloc(authRepository: repository);

      bloc.add(
        const AuthSignInRequested(
          email: AuthRepositoryImpl.otpRequiredEmail,
          password: '123456',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthOtpRequired>());

      await bloc.close();
      repository.dispose();
    });

    test('otp success emits AuthAuthenticated', () async {
      final repository = _FakeAuthRepository();
      final bloc = AuthBloc(authRepository: repository);

      bloc.add(
        const AuthSignInRequested(
          email: AuthRepositoryImpl.otpRequiredEmail,
          password: '123456',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const AuthOtpSubmitted(otp: AuthRepositoryImpl.validOtp));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthAuthenticated>());

      await bloc.close();
      repository.dispose();
    });

    test(
      'otp invalid emits AuthFailureState and keeps previous otp state',
      () async {
        final repository = _FakeAuthRepository();
        final bloc = AuthBloc(authRepository: repository);

        bloc.add(
          const AuthSignInRequested(
            email: AuthRepositoryImpl.otpRequiredEmail,
            password: '123456',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        bloc.add(const AuthOtpSubmitted(otp: '000000'));
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(bloc.state, isA<AuthFailureState>());
        final failure = bloc.state as AuthFailureState;
        expect(failure.failure, AuthFailure.invalidOtp);
        expect(failure.previous, isA<AuthOtpRequired>());

        await bloc.close();
        repository.dispose();
      },
    );

    test('sign out emits AuthUnauthenticated', () async {
      final repository = _FakeAuthRepository();
      final bloc = AuthBloc(authRepository: repository);

      bloc.add(
        const AuthSignInRequested(email: 'john@doe.com', password: '123456'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const AuthSignOutRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthUnauthenticated>());

      await bloc.close();
      repository.dispose();
    });

    test('repository session changes drive bloc state', () async {
      final repository = _FakeAuthRepository();
      final bloc = AuthBloc(authRepository: repository);

      repository.emitSession(
        const Session(accessToken: 'a', refreshToken: 'b'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state, isA<AuthAuthenticated>());

      repository.emitSession(const Session.empty());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state, isA<AuthUnauthenticated>());

      await bloc.close();
      repository.dispose();
    });
  });
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({Session? initialSession})
    : _currentSession = initialSession ?? const Session.empty();

  final StreamController<Session> _controller =
      StreamController<Session>.broadcast();

  Session _currentSession;
  String? _pendingChallenge;

  @override
  Session get currentSession => _currentSession;

  @override
  Stream<Session> get sessionStream => _controller.stream;

  @override
  Future<void> initialize() async {
    _controller.add(_currentSession);
  }

  @override
  Future<AuthResult> signIn(AuthCredentialsDto credentials) async {
    if (credentials.email == AuthRepositoryImpl.invalidCredentialsEmail) {
      throw const AuthException(failure: AuthFailure.invalidCredentials);
    }

    if (credentials.email == AuthRepositoryImpl.otpRequiredEmail) {
      _pendingChallenge = AuthRepositoryImpl.otpChallengeId;
      return const AuthOtpRequiredResult(
        challengeId: AuthRepositoryImpl.otpChallengeId,
        email: AuthRepositoryImpl.otpRequiredEmail,
      );
    }

    const session = Session(accessToken: 'access', refreshToken: 'refresh');
    const user = UserDto(
      profilePicture: 'https://example.com/avatar/john.png',
      username: 'john',
      name: 'John',
    );
    _currentSession = session;
    _controller.add(session);
    return const AuthSuccess(session: session, user: user);
  }

  @override
  Future<AuthResult> verifyOtp({
    required String challengeId,
    required String otp,
  }) async {
    if (_pendingChallenge == null || _pendingChallenge != challengeId) {
      throw const AuthException(failure: AuthFailure.otpChallengeMissing);
    }

    if (otp != AuthRepositoryImpl.validOtp) {
      throw const AuthException(failure: AuthFailure.invalidOtp);
    }

    const session = Session(accessToken: 'access', refreshToken: 'refresh');
    const user = UserDto(
      profilePicture: 'https://example.com/avatar/new.png',
      username: 'new',
      name: 'New',
    );
    _currentSession = session;
    _controller.add(session);
    return const AuthSuccess(session: session, user: user);
  }

  @override
  Future<void> signOut() async {
    _currentSession = const Session.empty();
    _controller.add(_currentSession);
  }

  void emitSession(Session session) {
    _currentSession = session;
    _controller.add(session);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
