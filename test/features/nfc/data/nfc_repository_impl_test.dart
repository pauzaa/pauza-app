import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:pauza/src/features/nfc/data/nfc_manager_client.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository_impl.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';
import 'package:pauza/src/features/nfc/model/nfc_errors.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('NfcRepositoryImpl', () {
    test('returns disabled when manager availability is false', () async {
      final repository = NfcRepositoryImpl(
        managerClient: _FakeNfcManagerClient(
          availability: NfcAvailability.disabled,
        ),
      );

      final availability = await repository.getAvailability();

      expect(availability, NfcChipAvailability.disabled);
    });

    test('maps discovered tag snapshot to NFC card DTO', () async {
      final repository = NfcRepositoryImpl(
        managerClient: _FakeNfcManagerClient(
          scanResult: const NfcTagSnapshot(
            uidHex: '01020304',
            techTypes: <NfcTagTech>[NfcTagTech.ndef, NfcTagTech.nfcA],
            isNdefFormatted: true,
            ndefRecords: <NfcNdefRecordDto>[
              NfcNdefRecordDto(
                tnf: 'wellKnown',
                typeHex: '54',
                identifierHex: '01',
                payloadHex: '02656e4869',
                payloadText: 'Hi',
              ),
            ],
            rawSnapshot: <String, Object?>{'nfca': <String, Object?>{}},
          ),
        ),
        uuid: const Uuid(),
      );

      final card = await repository.scanSingleCard();

      expect(card.uidHex, '01020304');
      expect(card.techTypes, <NfcTagTech>[NfcTagTech.ndef, NfcTagTech.nfcA]);
      expect(card.isNdefFormatted, isTrue);
      expect(card.ndefRecords.length, 1);
      expect(card.rawSnapshot, const <String, Object?>{
        'nfca': <String, Object?>{},
      });
      expect(card.id, isNotEmpty);
    });

    test('throws unsupported when availability is not supported', () async {
      final repository = NfcRepositoryImpl(
        managerClient: _FakeNfcManagerClient(
          checkAvailabilityError: UnsupportedError('unsupported'),
        ),
      );

      expect(
        repository.scanSingleCard,
        throwsA(
          isA<NfcException>().having(
            (exception) => exception.code,
            'code',
            NfcErrorCode.unsupported,
          ),
        ),
      );
    });

    test('forwards busy state', () async {
      final managerClient = _FakeNfcManagerClient(isSessionActive: true);
      final repository = NfcRepositoryImpl(managerClient: managerClient);

      expect(repository.isScanInProgress, isTrue);
    });
  });
}

final class _FakeNfcManagerClient implements NfcManagerClient {
  _FakeNfcManagerClient({
    this.availability = NfcAvailability.enabled,
    this.isSessionActive = false,
    this.scanResult,
    this.checkAvailabilityError,
  });

  final NfcAvailability availability;
  @override
  bool isSessionActive;
  final NfcTagSnapshot? scanResult;
  final Object? checkAvailabilityError;

  @override
  Future<NfcAvailability> checkAvailability() async {
    if (checkAvailabilityError case final error?) {
      throw error;
    }

    return availability;
  }

  @override
  Future<NfcTagSnapshot> scanSingleTag({required Duration timeout}) async {
    return scanResult ??
        const NfcTagSnapshot(
          uidHex: null,
          techTypes: <NfcTagTech>[NfcTagTech.unknown],
          isNdefFormatted: false,
          ndefRecords: <NfcNdefRecordDto>[],
          rawSnapshot: <String, Object?>{},
        );
  }

  @override
  Future<void> stopSession({
    String? alertMessage,
    String? errorMessage,
  }) async {}
}
