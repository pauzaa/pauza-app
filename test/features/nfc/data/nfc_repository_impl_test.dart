import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/nfc/model/nfc_platform_types.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';
import 'package:pauza/src/features/nfc/model/nfc_errors.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';
import 'package:uuid/uuid.dart';

import '../../../helpers/helpers.dart';

void main() {
  setUpAll(registerTestFallbackValues);

  group('NfcRepositoryImpl', () {
    late MockNfcOperations mockNfcOperations;

    setUp(() {
      mockNfcOperations = MockNfcOperations();
    });

    test('returns disabled when manager availability is false', () async {
      when(() => mockNfcOperations.checkAvailability()).thenAnswer((_) async => NfcPlatformAvailability.disabled);
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      final availability = await repository.getAvailability();

      expect(availability, NfcChipAvailability.disabled);
    });

    test('returns unknown when availability cannot be determined', () async {
      when(() => mockNfcOperations.checkAvailability()).thenAnswer((_) async => NfcPlatformAvailability.unknown);
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      final availability = await repository.getAvailability();

      expect(availability, NfcChipAvailability.unknown);
    });

    test('hasNfcSupport returns true when availability is available', () async {
      when(() => mockNfcOperations.checkAvailability()).thenAnswer((_) async => NfcPlatformAvailability.available);
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      final hasNfcSupport = await repository.hasNfcSupport();

      expect(hasNfcSupport, isTrue);
    });

    test('hasNfcSupport returns true when availability is disabled', () async {
      when(() => mockNfcOperations.checkAvailability()).thenAnswer((_) async => NfcPlatformAvailability.disabled);
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      final hasNfcSupport = await repository.hasNfcSupport();

      expect(hasNfcSupport, isTrue);
    });

    test('hasNfcSupport returns false when availability is not supported', () async {
      when(() => mockNfcOperations.checkAvailability()).thenAnswer((_) async => NfcPlatformAvailability.notSupported);
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      final hasNfcSupport = await repository.hasNfcSupport();

      expect(hasNfcSupport, isFalse);
    });

    test('hasNfcSupport returns false when availability is unknown', () async {
      when(() => mockNfcOperations.checkAvailability()).thenAnswer((_) async => NfcPlatformAvailability.unknown);
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      final hasNfcSupport = await repository.hasNfcSupport();

      expect(hasNfcSupport, isFalse);
    });

    test('hasNfcSupport returns false when availability check throws', () async {
      when(() => mockNfcOperations.checkAvailability()).thenThrow(Exception('boom'));
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      final hasNfcSupport = await repository.hasNfcSupport();

      expect(hasNfcSupport, isFalse);
    });

    test('maps discovered tag snapshot to NFC card DTO', () async {
      when(() => mockNfcOperations.checkAvailability()).thenAnswer((_) async => NfcPlatformAvailability.available);
      when(() => mockNfcOperations.scanSingleTag(timeout: any(named: 'timeout'))).thenAnswer(
        (_) async => NfcTagSnapshot(
          uidHex: NfcChipIdentifier.parse('01020304'),
          techTypes: IList(const <NfcTagTech>[NfcTagTech.ndef, NfcTagTech.nfcA]),
          isNdefFormatted: true,
          ndefRecords: IList(const <NfcNdefRecordDto>[
            NfcNdefRecordDto(
              tnf: 'wellKnown',
              typeHex: '54',
              identifierHex: '01',
              payloadHex: '02656e4869',
              payloadText: 'Hi',
            ),
          ]),
          rawSnapshot: IMap(const <String, Object?>{'nfca': <String, Object?>{}}),
        ),
      );
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations, uuid: const Uuid());

      final card = await repository.scanSingleCard();

      expect(card.uidHex, NfcChipIdentifier.parse('01020304'));
      expect(card.techTypes, <NfcTagTech>[NfcTagTech.ndef, NfcTagTech.nfcA]);
      expect(card.isNdefFormatted, isTrue);
      expect(card.ndefRecords.length, 1);
      expect(card.rawSnapshot.unlock, const <String, Object?>{'nfca': <String, Object?>{}});
      expect(card.id, isNotEmpty);
    });

    test('throws unsupported when availability is not supported', () async {
      when(() => mockNfcOperations.checkAvailability()).thenAnswer((_) async => NfcPlatformAvailability.notSupported);
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      expect(repository.scanSingleCard, throwsA(isA<NfcUnsupportedError>()));
    });

    test('forwards busy state', () async {
      when(() => mockNfcOperations.isSessionActive).thenReturn(true);
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      expect(repository.isScanInProgress, isTrue);
    });

    test('forwards NFC system settings support', () async {
      when(() => mockNfcOperations.canOpenSystemSettingsForNfc).thenReturn(true);
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      expect(repository.canOpenSystemSettingsForNfc, isTrue);
    });

    test('forwards opening NFC system settings', () async {
      when(() => mockNfcOperations.openSystemSettingsForNfc()).thenAnswer((_) async => true);
      final repository = NfcRepositoryImpl(managerClient: mockNfcOperations);

      final opened = await repository.openSystemSettingsForNfc();

      expect(opened, isTrue);
    });
  });
}
