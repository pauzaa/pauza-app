import 'dart:async';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:pauza/src/features/nfc/data/nfc_manager_client.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';
import 'package:pauza/src/features/nfc/model/nfc_errors.dart';
import 'package:uuid/uuid.dart';

abstract interface class NfcRepository {
  bool get isScanInProgress;

  Future<NfcChipAvailability> getAvailability();

  Future<NfcCardDto> scanSingleCard({
    Duration timeout = const Duration(seconds: 20),
  });

  Future<void> stopSession({String? alertMessage, String? errorMessage});
}

final class NfcRepositoryImpl implements NfcRepository {
  NfcRepositoryImpl({required NfcOperations managerClient, Uuid? uuid})
    : _managerClient = managerClient,
      _uuid = uuid ?? const Uuid();

  final NfcOperations _managerClient;
  final Uuid _uuid;

  @override
  bool get isScanInProgress => _managerClient.isSessionActive;

  @override
  Future<NfcChipAvailability> getAvailability() async {
    try {
      final availability = await _managerClient.checkAvailability();
      return switch (availability) {
        NfcAvailability.enabled => NfcChipAvailability.available,
        NfcAvailability.disabled => NfcChipAvailability.disabled,
        NfcAvailability.unsupported => NfcChipAvailability.notSupported,
      };
    } on Object catch (error) {
      throw NfcException.fromError(error);
    }
  }

  @override
  Future<NfcCardDto> scanSingleCard({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final availability = await getAvailability();

    if (availability == NfcChipAvailability.notSupported) {
      throw const NfcException(
        code: NfcErrorCode.unsupported,
        message: 'NFC is not supported on this platform/device.',
      );
    }

    if (availability == NfcChipAvailability.disabled) {
      throw const NfcException(
        code: NfcErrorCode.disabled,
        message: 'NFC is disabled on this device.',
      );
    }

    if (availability == NfcChipAvailability.unknown) {
      throw const NfcException(
        code: NfcErrorCode.unknown,
        message: 'NFC availability is unknown.',
      );
    }

    try {
      final snapshot = await _managerClient.scanSingleTag(timeout: timeout);

      return NfcCardDto(
        id: _uuid.v4(),
        detectedAt: DateTime.now().toUtc(),
        uidHex: snapshot.uidHex,
        techTypes: snapshot.techTypes,
        isNdefFormatted: snapshot.isNdefFormatted,
        ndefRecords: snapshot.ndefRecords,
        rawSnapshot: snapshot.rawSnapshot,
      );
    } on TimeoutException {
      throw const NfcException(
        code: NfcErrorCode.timeout,
        message: 'NFC scan timed out before a tag was discovered.',
      );
    } on Object catch (error) {
      throw NfcException.fromError(error);
    }
  }

  @override
  Future<void> stopSession({String? alertMessage, String? errorMessage}) async {
    await _managerClient.stopSession(
      alertMessage: alertMessage,
      errorMessage: errorMessage,
    );
  }
}
