import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/common/model/pauza_app_error.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/auth/common/model/auth_credentials_dto.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';

void main() {
  group('AuthBloc', () {
    test('initial state is AuthIdle', () {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      expect(bloc.state, isA<AuthIdle>());

      bloc.close();
      repository.dispose();
    });

    test('successful sign in emits AuthFlowSuccess', () async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      bloc.add(const AuthSignInRequested(email: 'john@doe.com', password: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthFlowSuccess>());

      await bloc.close();
      repository.dispose();
    });

    test('wrong credentials emit AuthFlowFailure invalidCredentials', () async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      bloc.add(const AuthSignInRequested(email: AuthRepositoryImpl.invalidCredentialsEmail, password: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthFlowFailure>());
      expect((bloc.state as AuthFlowFailure).error, const AuthException(failure: AuthFailure.invalidCredentials));

      await bloc.close();
      repository.dispose();
    });

    test('unknown email flow emits AuthOtpRequired', () async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      bloc.add(const AuthSignInRequested(email: AuthRepositoryImpl.otpRequiredEmail, password: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthOtpRequired>());

      await bloc.close();
      repository.dispose();
    });

    test('otp success emits AuthFlowSuccess', () async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      bloc.add(const AuthSignInRequested(email: AuthRepositoryImpl.otpRequiredEmail, password: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const AuthOtpSubmitted(otp: AuthRepositoryImpl.validOtp));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthFlowSuccess>());

      await bloc.close();
      repository.dispose();
    });

    test('otp invalid emits AuthFlowFailure and keeps previous otp state', () async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      bloc.add(const AuthSignInRequested(email: AuthRepositoryImpl.otpRequiredEmail, password: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const AuthOtpSubmitted(otp: '000000'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthFlowFailure>());
      final failure = bloc.state as AuthFlowFailure;
      expect(failure.error, const AuthException(failure: AuthFailure.invalidOtp));
      expect(failure.email, AuthRepositoryImpl.otpRequiredEmail);

      await bloc.close();
      repository.dispose();
    });

    test('otp submit without challenge emits otpChallengeMissing', () async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      bloc.add(const AuthOtpSubmitted(otp: AuthRepositoryImpl.validOtp));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthFlowFailure>());
      expect((bloc.state as AuthFlowFailure).error, const AuthException(failure: AuthFailure.otpChallengeMissing));

      await bloc.close();
      repository.dispose();
    });

    test('sign out emits AuthIdle', () async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      bloc.add(const AuthSignInRequested(email: 'john@doe.com', password: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const AuthSignOutRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthIdle>());

      await bloc.close();
      repository.dispose();
    });

    test('reset flow emits AuthIdle and clears pending OTP challenge', () async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      bloc.add(const AuthSignInRequested(email: AuthRepositoryImpl.otpRequiredEmail, password: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const AuthFlowResetRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthIdle>());
      expect(repository.clearPendingOtpChallengeCallCount, 1);

      await bloc.close();
      repository.dispose();
    });

    test('offline sign in emits failure and skips repository call', () async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard(canProceedResult: false);
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      bloc.add(const AuthSignInRequested(email: 'john@doe.com', password: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthFlowFailure>());
      expect((bloc.state as AuthFlowFailure).error, PauzaAppError.internetUnavailable);
      expect(repository.signInCalls, 0);

      await bloc.close();
      repository.dispose();
    });

    test('offline otp submit emits failure and skips repository call', () async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard(canProceedResult: false);
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

      bloc.add(const AuthSignInRequested(email: AuthRepositoryImpl.otpRequiredEmail, password: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const AuthOtpSubmitted(otp: AuthRepositoryImpl.validOtp));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AuthFlowFailure>());
      expect((bloc.state as AuthFlowFailure).error, PauzaAppError.internetUnavailable);
      expect(repository.verifyOtpCalls, 0);

      await bloc.close();
      repository.dispose();
    });
  });
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({Session? initialSession}) : _currentSession = initialSession ?? const Session.empty();

  final StreamController<Session> _controller = StreamController<Session>.broadcast();

  Session _currentSession;
  String? _pendingChallenge;
  int clearPendingOtpChallengeCallCount = 0;
  int signInCalls = 0;
  int verifyOtpCalls = 0;

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
    signInCalls += 1;
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
    const user = UserDto(profilePicture: 'https://example.com/avatar/john.png', username: 'john', name: 'John');
    _currentSession = session;
    _controller.add(session);
    return const AuthSuccess(session: session, user: user);
  }

  @override
  Future<AuthResult> verifyOtp({required String otp}) async {
    verifyOtpCalls += 1;
    if (_pendingChallenge == null) {
      throw const AuthException(failure: AuthFailure.otpChallengeMissing);
    }

    if (otp != AuthRepositoryImpl.validOtp) {
      throw const AuthException(failure: AuthFailure.invalidOtp);
    }

    const session = Session(accessToken: 'access', refreshToken: 'refresh');
    const user = UserDto(profilePicture: 'https://example.com/avatar/new.png', username: 'new', name: 'New');
    _currentSession = session;
    _controller.add(session);
    return const AuthSuccess(session: session, user: user);
  }

  @override
  Future<void> signOut() async {
    _currentSession = const Session.empty();
    _controller.add(_currentSession);
  }

  @override
  Future<void> clearPendingOtpChallenge() async {
    clearPendingOtpChallengeCallCount += 1;
    _pendingChallenge = null;
  }

  @override
  void dispose() {
    _controller.close();
  }
}

final class _FakeInternetRequiredGuard implements InternetRequiredGuard {
  _FakeInternetRequiredGuard({this.canProceedResult = true});

  final bool canProceedResult;

  @override
  bool get isHealthy => canProceedResult;

  @override
  Future<bool> canProceed({bool forceRefresh = true}) async => canProceedResult;
}
