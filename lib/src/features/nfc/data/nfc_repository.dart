import 'dart:async';

import 'package:pauza/src/features/nfc/data/nfc_util_client.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';
import 'package:pauza/src/features/nfc/model/nfc_errors.dart';
import 'package:pauza/src/features/nfc/model/nfc_platform_types.dart';
import 'package:uuid/uuid.dart';

abstract interface class NfcRepository {
  bool get isScanInProgress;

  bool get canOpenSystemSettingsForNfc;

  Future<bool> hasNfcSupport();

  Future<NfcChipAvailability> getAvailability();

  Future<bool> openSystemSettingsForNfc();

  Future<NfcCardDto> scanSingleCard({Duration timeout = const Duration(seconds: 20)});

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
  bool get canOpenSystemSettingsForNfc => _managerClient.canOpenSystemSettingsForNfc;

  @override
  Future<bool> hasNfcSupport() async {
    try {
      final availability = await getAvailability();
      return switch (availability) {
        NfcChipAvailability.available => true,
        NfcChipAvailability.disabled => true,
        NfcChipAvailability.notSupported => false,
        NfcChipAvailability.unknown => false,
      };
    } on Object {
      return false;
    }
  }

  @override
  Future<NfcChipAvailability> getAvailability() async {
    try {
      final availability = await _managerClient.checkAvailability();
      return switch (availability) {
        NfcPlatformAvailability.available => NfcChipAvailability.available,
        NfcPlatformAvailability.disabled => NfcChipAvailability.disabled,
        NfcPlatformAvailability.notSupported => NfcChipAvailability.notSupported,
        NfcPlatformAvailability.unknown => NfcChipAvailability.unknown,
      };
    } on Object catch (error) {
      throw NfcError.fromError(error);
    }
  }

  @override
  Future<bool> openSystemSettingsForNfc() async {
    return _managerClient.openSystemSettingsForNfc();
  }

  @override
  Future<NfcCardDto> scanSingleCard({Duration timeout = const Duration(seconds: 20)}) async {
    final availability = await getAvailability();

    if (availability == NfcChipAvailability.notSupported) {
      throw NfcUnsupportedError(availability: availability);
    }

    if (availability == NfcChipAvailability.disabled) {
      throw NfcDisabledError(availability: availability);
    }
    if (availability == NfcChipAvailability.unknown) {
      throw NfcUnknownError(availability: availability);
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
      throw const NfcTimeoutError();
    } on Object catch (error) {
      throw NfcError.fromError(error);
    }
  }

  @override
  Future<void> stopSession({String? alertMessage, String? errorMessage}) async {
    await _managerClient.stopSession(alertMessage: alertMessage, errorMessage: errorMessage);
  }
}
