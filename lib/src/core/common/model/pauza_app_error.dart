import 'package:pauza/src/core/localization/l10n.dart';

final class PauzaAppError implements Exception, Localizable {
  const PauzaAppError._(this._code);

  static const PauzaAppError internetUnavailable = PauzaAppError._(_PauzaAppErrorCode.internetUnavailable);
  static const PauzaAppError unknown = PauzaAppError._(_PauzaAppErrorCode.unknown);

  final _PauzaAppErrorCode _code;

  @override
  String localize(AppLocalizations localizations) {
    return switch (_code) {
      _PauzaAppErrorCode.internetUnavailable => localizations.internetRequiredToast,
      _PauzaAppErrorCode.unknown => localizations.errorTitle,
    };
  }

  @override
  String toString() {
    return 'PauzaAppError($_code)';
  }
}

enum _PauzaAppErrorCode { internetUnavailable, unknown }
