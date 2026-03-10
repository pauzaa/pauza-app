import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('initialize keeps empty session when storage has no value', () async {
      final storage = FakeAuthSessionStorage();
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

    group('requestOtp', () {
      test('returns AuthOtpRequiredResult without altering session', () async {
        final storage = FakeAuthSessionStorage();
        final repository = AuthRepositoryImpl(sessionStorage: storage);

        final result = await repository.requestOtp(email: 'john@doe.com');

        expect(result, isA<AuthOtpRequiredResult>());
        expect(result.email, 'john@doe.com');
        expect(repository.currentSession, const Session.empty());
        expect(storage.writtenSession, isNull);

        repository.dispose();
      });
    });

    group('resendOtp', () {
      test('returns AuthOtpRequiredResult with same email', () async {
        final storage = FakeAuthSessionStorage();
        final repository = AuthRepositoryImpl(sessionStorage: storage);

        await repository.requestOtp(email: 'john@doe.com');
        final result = await repository.resendOtp(email: 'john@doe.com');

        expect(result, isA<AuthOtpRequiredResult>());
        expect(result.email, 'john@doe.com');
        expect(repository.currentSession, const Session.empty());
        expect(storage.writtenSession, isNull);

        repository.dispose();
      });

      test('allows verifyOtp after resend', () async {
        final storage = FakeAuthSessionStorage();
        final repository = AuthRepositoryImpl(sessionStorage: storage);

        await repository.requestOtp(email: 'john@doe.com');
        await repository.resendOtp(email: 'john@doe.com');
        final result = await repository.verifyOtp(otp: AuthRepositoryImpl.validOtp);

        expect(result, isA<AuthSuccess>());
        expect(repository.currentSession.isAuthenticated, isTrue);

        repository.dispose();
      });

      test('succeeds without prior requestOtp and allows verifyOtp', () async {
        final storage = FakeAuthSessionStorage();
        final repository = AuthRepositoryImpl(sessionStorage: storage);

        final result = await repository.resendOtp(email: 'john@doe.com');

        expect(result, isA<AuthOtpRequiredResult>());
        expect(result.email, 'john@doe.com');

        // The challenge should be established, so verifyOtp should succeed.
        final verifyResult = await repository.verifyOtp(otp: AuthRepositoryImpl.validOtp);
        expect(verifyResult, isA<AuthSuccess>());
        expect(repository.currentSession.isAuthenticated, isTrue);

        repository.dispose();
      });
    });

    group('verifyOtp', () {
      test('throws AuthInvalidOtpError for wrong code', () async {
        final storage = FakeAuthSessionStorage();
        final repository = AuthRepositoryImpl(sessionStorage: storage);

        await repository.requestOtp(email: 'new@account.com');

        await expectLater(() => repository.verifyOtp(otp: '000000'), throwsA(isA<AuthInvalidOtpError>()));

        repository.dispose();
      });

      test('succeeds with valid OTP and emits authenticated session', () async {
        final storage = FakeAuthSessionStorage();
        final repository = AuthRepositoryImpl(sessionStorage: storage);
        final emitted = <Session>[];
        final sub = repository.sessionStream.listen(emitted.add);

        await repository.requestOtp(email: 'new@account.com');

        final result = await repository.verifyOtp(otp: AuthRepositoryImpl.validOtp);
        await Future<void>.delayed(Duration.zero);

        expect(result, isA<AuthSuccess>());
        expect(repository.currentSession.isAuthenticated, isTrue);
        expect(storage.writtenSession?.isAuthenticated, isTrue);
        expect(emitted.last.isAuthenticated, isTrue);

        await sub.cancel();
        repository.dispose();
      });

      test('throws AuthOtpChallengeMissingError without prior requestOtp', () async {
        final storage = FakeAuthSessionStorage();
        final repository = AuthRepositoryImpl(sessionStorage: storage);

        await expectLater(
          () => repository.verifyOtp(otp: AuthRepositoryImpl.validOtp),
          throwsA(isA<AuthOtpChallengeMissingError>()),
        );

        repository.dispose();
      });
    });

    group('clearPendingOtpChallenge', () {
      test('clears challenge so verifyOtp throws', () async {
        final storage = FakeAuthSessionStorage();
        final repository = AuthRepositoryImpl(sessionStorage: storage);

        await repository.requestOtp(email: 'john@doe.com');
        await repository.clearPendingOtpChallenge();

        await expectLater(
          () => repository.verifyOtp(otp: AuthRepositoryImpl.validOtp),
          throwsA(isA<AuthOtpChallengeMissingError>()),
        );

        repository.dispose();
      });
    });

    group('signOut', () {
      test('deletes session and emits Session.empty()', () async {
        final storage = FakeAuthSessionStorage();
        final repository = AuthRepositoryImpl(sessionStorage: storage);
        final emitted = <Session>[];
        final sub = repository.sessionStream.listen(emitted.add);

        await repository.requestOtp(email: 'john@doe.com');
        await repository.verifyOtp(otp: AuthRepositoryImpl.validOtp);
        await repository.signOut();
        await Future<void>.delayed(Duration.zero);

        expect(storage.deleteCallCount, 1);
        expect(repository.currentSession, const Session.empty());
        expect(emitted.last, const Session.empty());

        await sub.cancel();
        repository.dispose();
      });
    });

    group('sessionStream', () {
      test('emits each session mutation in order', () async {
        final storage = FakeAuthSessionStorage();
        final repository = AuthRepositoryImpl(sessionStorage: storage);
        final emitted = <Session>[];
        final sub = repository.sessionStream.listen(emitted.add);

        await repository.initialize();
        await repository.requestOtp(email: 'john@doe.com');
        await repository.verifyOtp(otp: AuthRepositoryImpl.validOtp);
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
  });
}

final class FakeAuthSessionStorage implements AuthSessionStorage {
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
