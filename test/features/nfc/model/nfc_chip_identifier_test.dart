import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';

void main() {
  group('NfcChipIdentifier', () {
    test('parse normalizes valid hex to lowercase', () {
      final identifier = NfcChipIdentifier.parse(' A1B2C3D4 ');

      expect(identifier.normalized, 'a1b2c3d4');
    });

    test('parse throws for empty value', () {
      expect(() => NfcChipIdentifier.parse('   '), throwsArgumentError);
    });

    test('parse throws for non-hex value', () {
      expect(() => NfcChipIdentifier.parse('zz11'), throwsArgumentError);
    });

    test('parse throws for odd-length hex value', () {
      expect(() => NfcChipIdentifier.parse('abc'), throwsArgumentError);
    });

    test('tryParse returns null for invalid values', () {
      expect(NfcChipIdentifier.tryParse('bad-value'), isNull);
    });
  });
}
