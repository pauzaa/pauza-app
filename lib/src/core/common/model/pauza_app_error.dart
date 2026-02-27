import 'package:pauza/src/core/localization/l10n.dart';

sealed class PauzaAppError implements Exception, Localizable {
  const PauzaAppError();
}

final class PauzaInternetUnavailableError extends PauzaAppError {
  const PauzaInternetUnavailableError();

  @override
  String localize(AppLocalizations localizations) => localizations.internetRequiredToast;

  @override
  String toString() => 'PauzaInternetUnavailableError';
}

final class PauzaUnknownError extends PauzaAppError {
  const PauzaUnknownError({this.cause});

  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'PauzaUnknownError(cause: $cause)';
}
