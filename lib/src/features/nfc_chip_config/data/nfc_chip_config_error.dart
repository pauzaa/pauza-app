import 'package:pauza/src/core/localization/l10n.dart';

sealed class NfcChipConfigError implements Exception, Localizable {
  const NfcChipConfigError();
}

class NfcChipConfigMissingIdentifierError extends NfcChipConfigError {
  const NfcChipConfigMissingIdentifierError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.nfcChipConfigUidMissingError;
  }
}

class NfcChipConfigAlreadyLinkedError extends NfcChipConfigError {
  const NfcChipConfigAlreadyLinkedError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.nfcChipConfigAlreadyLinked;
  }
}
