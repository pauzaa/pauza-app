import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_unlock_token.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('QrUnlockToken', () {
    test('generate creates canonical pauza:qr:v1:<uuid-v4> token', () {
      final token = QrUnlockToken.generate(uuid: const Uuid());
      final value = token.normalized;

      expect(value.startsWith('pauza:qr:v1:'), isTrue);
      expect(
        RegExp(r'^pauza:qr:v1:[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$').hasMatch(value),
        isTrue,
      );
    });

    test('parse accepts uppercase token and normalizes to lowercase', () {
      final token = QrUnlockToken.parse('PAUZA:QR:V1:3F2504E0-4F89-41D3-9A0C-0305E82C3301');

      expect(token.normalized, 'pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301');
    });

    test('parse trims surrounding whitespace', () {
      final token = QrUnlockToken.parse('  pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301  ');

      expect(token.normalized, 'pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301');
    });

    test('parse rejects invalid prefix, version, and uuid', () {
      expect(() => QrUnlockToken.parse('other:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301'), throwsArgumentError);
      expect(() => QrUnlockToken.parse('pauza:qr:v2:3f2504e0-4f89-41d3-9a0c-0305e82c3301'), throwsArgumentError);
      expect(() => QrUnlockToken.parse('pauza:qr:v1:not-a-uuid'), throwsArgumentError);
    });
  });
}
