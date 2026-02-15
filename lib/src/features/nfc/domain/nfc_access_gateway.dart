import 'package:flutter/material.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';

abstract interface class NfcAccessGateway {
  Future<NfcAccessResult> ensureReadyForScan();
}

enum NfcAccessBlockReason {
  unsupported,
  disabled,
  busy,
  permissionDenied,
  unknownError,
}

@immutable
class NfcAccessResult {
  const NfcAccessResult._({
    required this.isReady,
    required this.availability,
    required this.reason,
  });

  const NfcAccessResult.ready({required NfcChipAvailability availability})
    : this._(isReady: true, availability: availability, reason: null);

  const NfcAccessResult.blocked({
    required NfcChipAvailability availability,
    required NfcAccessBlockReason reason,
  }) : this._(isReady: false, availability: availability, reason: reason);

  final bool isReady;
  final NfcChipAvailability availability;
  final NfcAccessBlockReason? reason;
}

class NfcAccessGatewayImpl implements NfcAccessGateway {
  const NfcAccessGatewayImpl({required NfcRepository repository})
    : _repository = repository;

  final NfcRepository _repository;

  @override
  Future<NfcAccessResult> ensureReadyForScan() async {
    if (_repository.isScanInProgress) {
      return const NfcAccessResult.blocked(
        availability: NfcChipAvailability.unknown,
        reason: NfcAccessBlockReason.busy,
      );
    }

    try {
      final availability = await _repository.getAvailability();
      return switch (availability) {
        NfcChipAvailability.available => NfcAccessResult.ready(
          availability: availability,
        ),
        NfcChipAvailability.disabled => const NfcAccessResult.blocked(
          availability: NfcChipAvailability.disabled,
          reason: NfcAccessBlockReason.disabled,
        ),
        NfcChipAvailability.notSupported => const NfcAccessResult.blocked(
          availability: NfcChipAvailability.notSupported,
          reason: NfcAccessBlockReason.unsupported,
        ),
        NfcChipAvailability.unknown => const NfcAccessResult.blocked(
          availability: NfcChipAvailability.unknown,
          reason: NfcAccessBlockReason.unknownError,
        ),
      };
    } on Object {
      return const NfcAccessResult.blocked(
        availability: NfcChipAvailability.unknown,
        reason: NfcAccessBlockReason.unknownError,
      );
    }
  }
}
