import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/profile/edit/bloc/user_name_checker_bloc.dart';

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

  static String? validateName(String? value, AppLocalizations l10n) {
    if ((value ?? '').trim().isEmpty) {
      return l10n.modeRequiredFieldError;
    }
    return null;
  }

  /// Validates a username string.
  ///
  /// Requires 3-30 characters, only lowercase letters, digits, or underscore.
  /// Returns a localized error message if invalid, or null if valid.
  static String? validateUsername(
    String? value,
    AppLocalizations l10n,
    UsernameAvailability usernameAvailability,
  ) {
    final candidate = (value ?? '').trim();
    if (candidate.isEmpty) {
      return l10n.profileEditInvalidUsernameError;
    }
    const pattern = r'^[a-z0-9_]{3,30}$';
    if (!RegExp(pattern).hasMatch(candidate)) {
      return l10n.profileEditInvalidUsernameError;
    }
    if (usernameAvailability == UsernameAvailability.taken) {
      return l10n.profileEditUsernameTakenError;
    }
    return null;
  }

  static bool isUsernameValid(String? value) {
    final candidate = (value ?? '').trim();
    if (candidate.isEmpty) {
      return false;
    }
    return RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(candidate);
  }
}
