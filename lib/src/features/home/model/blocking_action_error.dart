import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';

sealed class BlockingActionError implements Exception, Localizable {
  const BlockingActionError();
}

final class ActiveModeUnavailableError extends BlockingActionError {
  const ActiveModeUnavailableError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionBlockedModeUnavailable;
  }
}

final class PauseLimitReachedError extends BlockingActionError {
  const PauseLimitReachedError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homePauseBlockedByLimit;
  }
}

final class MinimumDurationNotReachedError extends BlockingActionError {
  const MinimumDurationNotReachedError({required this.remaining});

  final Duration remaining;

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionBlockedByMinimumDuration(remaining.formatTimerHhMmSs());
  }
}

final class ScenarioProofRequiredError extends BlockingActionError {
  const ScenarioProofRequiredError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionScenarioProofRequired;
  }
}

final class NfcScanMissingIdentifierError extends BlockingActionError {
  const NfcScanMissingIdentifierError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionNfcMissingIdentifier;
  }
}

final class NfcChipNotLinkedError extends BlockingActionError {
  const NfcChipNotLinkedError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionNfcNotLinked;
  }
}

final class QrCodeInvalidError extends BlockingActionError {
  const QrCodeInvalidError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionQrInvalid;
  }
}

final class QrCodeNotLinkedError extends BlockingActionError {
  const QrCodeNotLinkedError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionQrNotLinked;
  }
}

final class NfcStartConfigurationMissingError extends BlockingActionError {
  const NfcStartConfigurationMissingError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionStartNfcConfigRequired;
  }
}

final class QrStartConfigurationMissingError extends BlockingActionError {
  const QrStartConfigurationMissingError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionStartQrConfigRequired;
  }
}
