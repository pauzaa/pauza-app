import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/auth/common/model/auth_credentials_dto.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('initialize keeps empty session when storage has no value', () async {
      final storage = _FakeAuthSessionStorage();
      final repository = AuthRepositoryImpl(sessionStorage: storage);
      final emitted = <Session>[];
      final sub = repository.sessionStream.listen(emitted.add);

      await repository.initialize();
      await Future<void>.delayed(Duration.zero);

      expect(repository.currentSession, const Session.empty());
      expect(emitted, <Session>[const Session.empty()]);

      await sub.cancel();
      repository.dispose();
    });

    test('signIn with regular email returns success and emits session', () async {
      final storage = _FakeAuthSessionStorage();
      final repository = AuthRepositoryImpl(sessionStorage: storage);
      final emitted = <Session>[];
      final sub = repository.sessionStream.listen(emitted.add);

      final result = await repository.signIn(const AuthCredentialsDto(email: 'john@doe.com', password: '123456'));
      await Future<void>.delayed(Duration.zero);

      expect(result, isA<AuthSuccess>());
      expect(repository.currentSession.isAuthenticated, isTrue);
      expect(storage.writtenSession?.isAuthenticated, isTrue);
      expect(emitted.last.isAuthenticated, isTrue);

      await sub.cancel();
      repository.dispose();
    });

    test('signIn throws invalidCredentials for wrong@credentials.com', () async {
      final storage = _FakeAuthSessionStorage();
      final repository = AuthRepositoryImpl(sessionStorage: storage);

      await expectLater(
        () => repository.signIn(const AuthCredentialsDto(email: AuthRepositoryImpl.invalidCredentialsEmail, password: 'secret')),
        throwsA(isA<AuthException>().having((error) => error.failure, 'failure', AuthFailure.invalidCredentials)),
      );

      expect(repository.currentSession, const Session.empty());
      expect(storage.writtenSession, isNull);

      repository.dispose();
    });

    test('signIn returns otp required for new@account.com', () async {
      final storage = _FakeAuthSessionStorage();
      final repository = AuthRepositoryImpl(sessionStorage: storage);

      final result = await repository.signIn(const AuthCredentialsDto(email: AuthRepositoryImpl.otpRequiredEmail, password: 'secret'));

      expect(result, isA<AuthOtpRequiredResult>());
      expect(repository.currentSession, const Session.empty());
      expect(storage.writtenSession, isNull);

      repository.dispose();
    });

    test('verifyOtp throws invalidOtp for wrong code', () async {
      final storage = _FakeAuthSessionStorage();
      final repository = AuthRepositoryImpl(sessionStorage: storage);

      await repository.signIn(const AuthCredentialsDto(email: AuthRepositoryImpl.otpRequiredEmail, password: 'secret'));

      await expectLater(
        () => repository.verifyOtp(otp: '000000'),
        throwsA(isA<AuthException>().having((error) => error.failure, 'failure', AuthFailure.invalidOtp)),
      );

      repository.dispose();
    });

    test('verifyOtp succeeds with 111111 and emits authenticated session', () async {
      final storage = _FakeAuthSessionStorage();
      final repository = AuthRepositoryImpl(sessionStorage: storage);
      final emitted = <Session>[];
      final sub = repository.sessionStream.listen(emitted.add);

      await repository.signIn(const AuthCredentialsDto(email: AuthRepositoryImpl.otpRequiredEmail, password: 'secret'));

      final result = await repository.verifyOtp(otp: AuthRepositoryImpl.validOtp);
      await Future<void>.delayed(Duration.zero);

      expect(result, isA<AuthSuccess>());
      expect(repository.currentSession.isAuthenticated, isTrue);
      expect(storage.writtenSession?.isAuthenticated, isTrue);
      expect(emitted.last.isAuthenticated, isTrue);

      await sub.cancel();
      repository.dispose();
    });

    test('signOut deletes session and emits Session.empty()', () async {
      final storage = _FakeAuthSessionStorage();
      final repository = AuthRepositoryImpl(sessionStorage: storage);
      final emitted = <Session>[];
      final sub = repository.sessionStream.listen(emitted.add);

      await repository.signIn(const AuthCredentialsDto(email: 'john@doe.com', password: '123456'));
      await repository.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(storage.deleteCallCount, 1);
      expect(repository.currentSession, const Session.empty());
      expect(emitted.last, const Session.empty());

      await sub.cancel();
      repository.dispose();
    });

    test('sessionStream emits each session mutation in order', () async {
      final storage = _FakeAuthSessionStorage();
      final repository = AuthRepositoryImpl(sessionStorage: storage);
      final emitted = <Session>[];
      final sub = repository.sessionStream.listen(emitted.add);

      await repository.initialize();
      await repository.signIn(const AuthCredentialsDto(email: 'john@doe.com', password: '123456'));
      await repository.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(emitted.length, 3);
      expect(emitted[0], const Session.empty());
      expect(emitted[1].isAuthenticated, isTrue);
      expect(emitted[2], const Session.empty());

      await sub.cancel();
      repository.dispose();
    });
  });
}

final class _FakeAuthSessionStorage implements AuthSessionStorage {
  Session storedSession = const Session.empty();
  Session? writtenSession;
  int deleteCallCount = 0;

  @override
  Future<void> deleteSession() async {
    deleteCallCount += 1;
    storedSession = const Session.empty();
  }

  @override
  Future<Session> readSession() async {
    return storedSession;
  }

  @override
  Future<void> writeSession(Session session) async {
    writtenSession = session;
    storedSession = session;
  }
}
