import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';

void main() {
  group('NfcNdefRecordDto', () {
    test('serializes and deserializes JSON', () {
      const dto = NfcNdefRecordDto(
        tnf: 'wellKnown',
        typeHex: '54',
        identifierHex: '0102',
        payloadHex: '02656e48656c6c6f',
        payloadText: 'Hello',
      );

      final json = dto.toJson();
      final restored = NfcNdefRecordDto.fromJson(json);

      expect(restored, dto);
    });

    test('uses defaults for missing JSON fields', () {
      final restored = NfcNdefRecordDto.fromJson(const <String, Object?>{});

      expect(restored.tnf, '');
      expect(restored.typeHex, '');
      expect(restored.identifierHex, '');
      expect(restored.payloadHex, '');
      expect(restored.payloadText, isNull);
    });
  });
}
