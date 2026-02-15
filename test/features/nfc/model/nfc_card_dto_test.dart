import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';

void main() {
  group('NfcCardDto', () {
    test('serializes and deserializes JSON', () {
      final detectedAt = DateTime.utc(2026, 1, 1, 10, 30);
      const record = NfcNdefRecordDto(
        tnf: 'wellKnown',
        typeHex: '54',
        identifierHex: '01',
        payloadHex: '02656e4869',
        payloadText: 'Hi',
      );

      final dto = NfcCardDto(
        id: 'card-id-1',
        detectedAt: detectedAt,
        uidHex: 'a1b2c3d4',
        techTypes: const <NfcTagTech>[NfcTagTech.ndef, NfcTagTech.nfcA],
        isNdefFormatted: true,
        ndefRecords: const <NfcNdefRecordDto>[record],
        rawSnapshot: const <String, Object?>{
          'ndef': <String, Object?>{
            'identifier': <int>[1, 2, 3, 4],
          },
          'meta': <Object?>['x', 1],
        },
      );

      final restored = NfcCardDto.fromJson(dto.toJson());

      expect(restored, dto);
    });

    test('uses safe defaults for malformed JSON', () {
      final restored = NfcCardDto.fromJson(const <String, Object?>{});

      expect(restored.id, '');
      expect(restored.uidHex, isNull);
      expect(restored.techTypes, isEmpty);
      expect(restored.isNdefFormatted, isFalse);
      expect(restored.ndefRecords, isEmpty);
      expect(restored.rawSnapshot, isEmpty);
    });
  });
}
