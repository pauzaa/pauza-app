import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/nfc/data/nfc_util_client.dart';
import 'package:pauza/src/features/nfc/model/nfc_platform_types.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';
import 'package:pauza/src/features/nfc/model/nfc_errors.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('NfcRepositoryImpl', () {
    test('returns disabled when manager availability is false', () async {
      final repository = NfcRepositoryImpl(managerClient: _FakeNfcManagerClient(availability: NfcPlatformAvailability.disabled));

      final availability = await repository.getAvailability();

      expect(availability, NfcChipAvailability.disabled);
    });

    test('throws unknown when availability cannot be determined', () async {
      final repository = NfcRepositoryImpl(managerClient: _FakeNfcManagerClient(availability: NfcPlatformAvailability.unknown));

      expect(repository.getAvailability, throwsA(isA<NfcException>().having((exception) => exception.code, 'code', NfcErrorCode.unknown)));
    });

    test('maps discovered tag snapshot to NFC card DTO', () async {
      final repository = NfcRepositoryImpl(
        managerClient: _FakeNfcManagerClient(
          scanResult: NfcTagSnapshot(
            uidHex: '01020304',
            techTypes: IList(const <NfcTagTech>[NfcTagTech.ndef, NfcTagTech.nfcA]),
            isNdefFormatted: true,
            ndefRecords: IList(const <NfcNdefRecordDto>[
              NfcNdefRecordDto(tnf: 'wellKnown', typeHex: '54', identifierHex: '01', payloadHex: '02656e4869', payloadText: 'Hi'),
            ]),
            rawSnapshot: IMap(const <String, Object?>{'nfca': <String, Object?>{}}),
          ),
        ),
        uuid: const Uuid(),
      );

      final card = await repository.scanSingleCard();

      expect(card.uidHex, '01020304');
      expect(card.techTypes, <NfcTagTech>[NfcTagTech.ndef, NfcTagTech.nfcA]);
      expect(card.isNdefFormatted, isTrue);
      expect(card.ndefRecords.length, 1);
      expect(card.rawSnapshot.unlock, const <String, Object?>{'nfca': <String, Object?>{}});
      expect(card.id, isNotEmpty);
    });

    test('throws unsupported when availability is not supported', () async {
      final repository = NfcRepositoryImpl(managerClient: _FakeNfcManagerClient(checkAvailabilityError: UnsupportedError('unsupported')));

      expect(
        repository.scanSingleCard,
        throwsA(isA<NfcException>().having((exception) => exception.code, 'code', NfcErrorCode.unsupported)),
      );
    });

    test('forwards busy state', () async {
      final managerClient = _FakeNfcManagerClient(isSessionActive: true);
      final repository = NfcRepositoryImpl(managerClient: managerClient);

      expect(repository.isScanInProgress, isTrue);
    });

    test('forwards NFC system settings support', () async {
      final managerClient = _FakeNfcManagerClient(canOpenSystemSettingsForNfc: true);
      final repository = NfcRepositoryImpl(managerClient: managerClient);

      expect(repository.canOpenSystemSettingsForNfc, isTrue);
    });

    test('forwards opening NFC system settings', () async {
      final managerClient = _FakeNfcManagerClient(openSystemSettingsResult: true);
      final repository = NfcRepositoryImpl(managerClient: managerClient);

      final opened = await repository.openSystemSettingsForNfc();

      expect(opened, isTrue);
    });
  });
}

final class _FakeNfcManagerClient implements NfcOperations {
  _FakeNfcManagerClient({
    this.availability = NfcPlatformAvailability.available,
    this.isSessionActive = false,
    this.scanResult,
    this.checkAvailabilityError,
    this.canOpenSystemSettingsForNfc = false,
    this.openSystemSettingsResult = false,
  });

  final NfcPlatformAvailability availability;
  @override
  bool isSessionActive;
  final NfcTagSnapshot? scanResult;
  final Object? checkAvailabilityError;
  @override
  final bool canOpenSystemSettingsForNfc;
  final bool openSystemSettingsResult;

  @override
  Future<NfcPlatformAvailability> checkAvailability() async {
    if (checkAvailabilityError case final error?) {
      throw error;
    }

    return availability;
  }

  @override
  Future<NfcTagSnapshot> scanSingleTag({required Duration timeout}) async {
    return scanResult ??
        NfcTagSnapshot(
          uidHex: null,
          techTypes: IList(const <NfcTagTech>[NfcTagTech.unknown]),
          isNdefFormatted: false,
          ndefRecords: IList(const <NfcNdefRecordDto>[]),
          rawSnapshot: IMap(const <String, Object?>{}),
        );
  }

  @override
  Future<bool> openSystemSettingsForNfc() async => openSystemSettingsResult;

  @override
  Future<void> stopSession({String? alertMessage, String? errorMessage}) async {}
}
