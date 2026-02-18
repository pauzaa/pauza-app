import 'package:flutter/material.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';

enum NfcErrorCode { unsupported, disabled, busy, permissionDenied, timeout, cancelled, unknown }

@immutable
class NfcException implements Exception {
  const NfcException({required this.code, required this.message, this.cause, this.nfcAvailability});

  factory NfcException.fromError(Object error) {
    if (error is NfcException) {
      return error;
    }

    final message = error.toString().toLowerCase();

    if (message.contains('busy')) {
      return NfcException(code: NfcErrorCode.busy, message: 'Another NFC session is already active.', cause: error);
    }

    if (message.contains('permission') || message.contains('denied') || message.contains('unauthorized')) {
      return NfcException(code: NfcErrorCode.permissionDenied, message: 'NFC permission was denied.', cause: error);
    }

    if (message.contains('cancel')) {
      return NfcException(code: NfcErrorCode.cancelled, message: 'NFC scan session was cancelled.', cause: error);
    }

    if (message.contains('timeout')) {
      return NfcException(code: NfcErrorCode.timeout, message: 'NFC scan timed out before a tag was discovered.', cause: error);
    }

    if (message.contains('unsupported')) {
      return NfcException(code: NfcErrorCode.unsupported, message: 'NFC is not supported on this platform/device.', cause: error);
    }

    return NfcException(code: NfcErrorCode.unknown, message: 'Unexpected NFC error.', cause: error);
  }

  final NfcErrorCode code;
  final NfcChipAvailability? nfcAvailability;
  final String message;
  final Object? cause;

  @override
  String toString() {
    return 'NfcException(code: $code, message: $message, cause: $cause)';
  }
}
