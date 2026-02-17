import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/auth/common/model/auth_credentials_dto.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/auth/domain/auth_gate.dart';

void main() {
  group('PauzaAuthGateNotifier', () {
    test('updates authentication flag when repository emits session', () async {
      final repository = _FakeAuthRepository();
      final gate = PauzaAuthGateNotifier(authRepository: repository);

      var notificationCount = 0;
      gate.addListener(() {
        notificationCount += 1;
      });

      repository.emitSession(
        const Session(accessToken: 'a', refreshToken: 'b'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(gate.isAuthenticated, isTrue);
      expect(notificationCount, 1);

      repository.emitSession(const Session.empty());
      await Future<void>.delayed(Duration.zero);

      expect(gate.isAuthenticated, isFalse);
      expect(notificationCount, 2);

      gate.dispose();
      repository.dispose();
    });
  });
}

final class _FakeAuthRepository implements AuthRepository {
  final StreamController<Session> _controller =
      StreamController<Session>.broadcast();

  Session _currentSession = const Session.empty();

  @override
  Session get currentSession => _currentSession;

  @override
  Stream<Session> get sessionStream => _controller.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<AuthResult> signIn(AuthCredentialsDto credentials) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> verifyOtp({
    required String otp,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

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
