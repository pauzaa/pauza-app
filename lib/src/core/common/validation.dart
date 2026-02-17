import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';

/// Global validation helpers.
abstract final class PauzaValidators {
  PauzaValidators._();

  /// Validates an email string.
  ///
  /// Returns a localized error message if invalid, or null if valid.
  static String? validateEmail(String? value, AppLocalizations l10n) {
    final candidate = value?.trim() ?? '';
    if (candidate.isEmpty) {
      return l10n.authValidationRequired;
    }

    const pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(candidate)) {
      return l10n.authValidationInvalidEmail;
    }

    return null;
  }

  /// Validates a password string.
  ///
  /// Returns a localized error message if invalid, or null if valid.
  static String? validatePassword(String? value, AppLocalizations l10n) {
    if ((value ?? '').trim().isEmpty) {
      return l10n.authValidationRequired;
    }
    return null;
  }
}
