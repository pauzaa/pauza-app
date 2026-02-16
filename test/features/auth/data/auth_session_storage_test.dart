import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureAuthSessionStorage', () {
    test('readSession returns empty when storage has no value', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      final storage = SecureAuthSessionStorage();

      final session = await storage.readSession();

      expect(session, const Session.empty());
    });

    test('writeSession + readSession roundtrip works', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      final storage = SecureAuthSessionStorage();
      const session = Session(accessToken: 'access', refreshToken: 'refresh');

      await storage.writeSession(session);
      final restored = await storage.readSession();

      expect(restored, session);
    });

    test('deleteSession clears persisted session', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      final storage = SecureAuthSessionStorage();
      const session = Session(accessToken: 'access', refreshToken: 'refresh');

      await storage.writeSession(session);
      await storage.deleteSession();
      final restored = await storage.readSession();

      expect(restored, const Session.empty());
    });

    test('readSession throws storageFailure for malformed payload', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        'auth.session': 'not-json',
      });
      final storage = SecureAuthSessionStorage();

      await expectLater(
        storage.readSession,
        throwsA(
          isA<AuthException>().having(
            (error) => error.failure,
            'failure',
            AuthFailure.storageFailure,
          ),
        ),
      );
    });
  });
}
