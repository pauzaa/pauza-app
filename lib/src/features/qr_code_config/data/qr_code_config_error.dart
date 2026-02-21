import 'package:pauza/src/core/localization/l10n.dart';

sealed class QrCodeConfigError implements Exception, Localizable {
  const QrCodeConfigError();
}

final class QrCodeConfigInvalidScanValueError extends QrCodeConfigError {
  const QrCodeConfigInvalidScanValueError({required this.scanValue, required this.cause});

  final String scanValue;
  final Object cause;

  @override
  String localize(AppLocalizations localizations) {
    return localizations.qrCodeConfigActionFailed;
  }
}

final class QrCodeConfigGenerationError extends QrCodeConfigError {
  const QrCodeConfigGenerationError({required this.cause});

  final Object cause;

  @override
  String localize(AppLocalizations localizations) {
    return localizations.qrCodeConfigGenerateFailed;
  }
}

final class QrCodeConfigRenameFailedError extends QrCodeConfigError {
  const QrCodeConfigRenameFailedError({required this.cause});

  final Object cause;

  @override
  String localize(AppLocalizations localizations) {
    return localizations.qrCodeConfigRenameFailed;
  }
}

final class QrCodeConfigDeleteFailedError extends QrCodeConfigError {
  const QrCodeConfigDeleteFailedError({required this.cause});

  final Object cause;

  @override
  String localize(AppLocalizations localizations) {
    return localizations.qrCodeConfigDeleteFailed;
  }
}
