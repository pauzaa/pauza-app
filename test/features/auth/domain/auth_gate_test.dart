import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/auth/domain/auth_gate.dart';

void main() {
  group('PauzaAuthGateNotifier', () {
    test('initially reflects repository session', () {
      final repository = FakeAuthRepository();
      final gate = PauzaAuthGateNotifier(authRepository: repository);

      expect(gate.session, const Session.empty());
      expect(gate.isAuthenticated, isFalse);

      gate.dispose();
      repository.dispose();
    });

    test('updates authentication flag when repository emits session', () async {
      final repository = FakeAuthRepository();
      final gate = PauzaAuthGateNotifier(authRepository: repository);

      var notificationCount = 0;
      gate.addListener(() {
        notificationCount += 1;
      });

      final authenticated = repository.emitSession(const Session(accessToken: 'a', refreshToken: 'b'));
      await authenticated;

      expect(gate.isAuthenticated, isTrue);
      expect(notificationCount, 1);

      final unauthenticated = repository.emitSession(const Session.empty());
      await unauthenticated;

      expect(gate.isAuthenticated, isFalse);
      expect(notificationCount, 2);

      gate.dispose();
      repository.dispose();
    });

    test('stops listening after dispose', () async {
      final repository = FakeAuthRepository();
      final gate = PauzaAuthGateNotifier(authRepository: repository);

      var notificationCount = 0;
      gate.addListener(() {
        notificationCount += 1;
      });

      gate.dispose();

      // Emitting after dispose should not crash or notify.
      repository.emitSession(const Session(accessToken: 'a', refreshToken: 'b'));
      await Future<void>.delayed(Duration.zero);

      expect(notificationCount, 0);

      repository.dispose();
    });

    test('session getter always returns current repository session', () async {
      final repository = FakeAuthRepository();
      final gate = PauzaAuthGateNotifier(authRepository: repository);

      const authenticated = Session(accessToken: 'tok', refreshToken: 'ref');
      await repository.emitSession(authenticated);

      expect(gate.session, authenticated);

      gate.dispose();
      repository.dispose();
    });
  });
}

final class FakeAuthRepository implements AuthRepository {
  final StreamController<Session> _controller = StreamController<Session>.broadcast();

  Session _currentSession = const Session.empty();

  @override
  Session get currentSession => _currentSession;

  @override
  Stream<Session> get sessionStream => _controller.stream;

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
  Future<void> signOut() async {}

  @override
  Future<void> forceLocalSignOut() async {}

  @override
  Future<void> clearPendingOtpChallenge() async {}

  @override
  Future<String?> refreshSession() async => null;

  /// Emits a session and returns a [Future] that completes after listeners
  /// have been notified (one microtask later).
  Future<void> emitSession(Session session) {
    _currentSession = session;
    _controller.add(session);
    return Future<void>.delayed(Duration.zero);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
