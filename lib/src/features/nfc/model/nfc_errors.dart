import 'package:flutter/material.dart';
import 'package:nfc_util/nfc_util.dart' as nfc_util;
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';

@immutable
sealed class NfcError implements Exception, Localizable {
  const NfcError({this.availability, this.cause});

  final NfcChipAvailability? availability;
  final Object? cause;

  factory NfcError.fromError(Object error) {
    if (error is NfcError) {
      return error;
    }

    final message = error.toString().toLowerCase();

    if (message.contains('busy')) {
      return NfcBusyError(cause: error);
    }

    if (message.contains('permission') || message.contains('denied') || message.contains('unauthorized')) {
      return NfcPermissionDeniedError(cause: error);
    }

    if (message.contains('cancel')) {
      return NfcCancelledError(cause: error);
    }

    if (message.contains('timeout')) {
      return NfcTimeoutError(cause: error);
    }

    if (message.contains('unsupported')) {
      return NfcUnsupportedError(cause: error);
    }

    return NfcUnknownError(cause: error);
  }

  factory NfcError.fromNfcError(nfc_util.NfcError error) {
    return switch (error.type) {
      nfc_util.NfcErrorType.sessionTimeout => const NfcTimeoutError(),
      nfc_util.NfcErrorType.systemIsBusy => const NfcBusyError(),
      nfc_util.NfcErrorType.userCanceled => const NfcCancelledError(),
      nfc_util.NfcErrorType.unknown => NfcUnknownError(cause: error),
    };
  }
}

final class NfcUnsupportedError extends NfcError {
  const NfcUnsupportedError({super.availability, super.cause});

  @override
  String localize(AppLocalizations localizations) => localizations.nfcChipConfigScanFailed;

  @override
  String toString() => 'NfcUnsupportedError(availability: $availability, cause: $cause)';
}

final class NfcDisabledError extends NfcError {
  const NfcDisabledError({super.availability, super.cause});

  @override
  String localize(AppLocalizations localizations) => localizations.nfcChipConfigScanFailed;

  @override
  String toString() => 'NfcDisabledError(availability: $availability, cause: $cause)';
}

final class NfcBusyError extends NfcError {
  const NfcBusyError({super.availability, super.cause});

  @override
  String localize(AppLocalizations localizations) => localizations.nfcChipConfigScanFailed;

  @override
  String toString() => 'NfcBusyError(availability: $availability, cause: $cause)';
}

final class NfcPermissionDeniedError extends NfcError {
  const NfcPermissionDeniedError({super.availability, super.cause});

  @override
  String localize(AppLocalizations localizations) => localizations.nfcChipConfigScanFailed;

  @override
  String toString() => 'NfcPermissionDeniedError(availability: $availability, cause: $cause)';
}

final class NfcTimeoutError extends NfcError {
  const NfcTimeoutError({super.availability, super.cause});

  @override
  String localize(AppLocalizations localizations) => localizations.nfcChipConfigScanFailed;

  @override
  String toString() => 'NfcTimeoutError(availability: $availability, cause: $cause)';
}

final class NfcCancelledError extends NfcError {
  const NfcCancelledError({super.availability, super.cause});

  @override
  String localize(AppLocalizations localizations) => localizations.nfcChipConfigScanFailed;

  @override
  String toString() => 'NfcCancelledError(availability: $availability, cause: $cause)';
}

final class NfcUnknownError extends NfcError {
  const NfcUnknownError({super.availability, super.cause});

  @override
  String localize(AppLocalizations localizations) => localizations.nfcChipConfigScanFailed;

  @override
  String toString() => 'NfcUnknownError(availability: $availability, cause: $cause)';
}
