import 'package:flutter/material.dart';
import 'package:nfc_util/nfc_util.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';

enum NfcErrorCode implements Localizable {
  unsupported,
  disabled,
  busy,
  permissionDenied,
  timeout,
  cancelled,
  unknown;

  @override
  String localize(AppLocalizations localizations) {
    return localizations.nfcChipConfigScanFailed;
  }
}

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

  factory NfcException.fromNfcError(NfcError error) {
    return switch (error.type) {
      NfcErrorType.sessionTimeout => const NfcException(
        code: NfcErrorCode.timeout,
        message: 'NFC scan timed out before a tag was discovered.',
      ),
      NfcErrorType.systemIsBusy => const NfcException(code: NfcErrorCode.busy, message: 'Another NFC session is already active.'),
      NfcErrorType.userCanceled => const NfcException(code: NfcErrorCode.cancelled, message: 'NFC scan session was cancelled.'),
      NfcErrorType.unknown => NfcException(code: NfcErrorCode.unknown, message: error.message, cause: error),
    };
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
