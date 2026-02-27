import 'package:pauza/src/core/localization/l10n.dart';

/// Sealed hierarchy of authentication errors.
///
/// Each variant implements [Exception] and [Localizable] so that
/// error objects can be thrown, caught by type, and localized
/// without enum-code extraction.
sealed class AuthError implements Exception, Localizable {
  const AuthError();
}

final class AuthInvalidCredentialsError extends AuthError {
  const AuthInvalidCredentialsError();

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureInvalidCredentials;

  @override
  String toString() => 'AuthInvalidCredentialsError';
}

final class AuthInvalidOtpError extends AuthError {
  const AuthInvalidOtpError();

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureInvalidOtp;

  @override
  String toString() => 'AuthInvalidOtpError';
}

final class AuthOtpChallengeMissingError extends AuthError {
  const AuthOtpChallengeMissingError();

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureOtpChallengeMissing;

  @override
  String toString() => 'AuthOtpChallengeMissingError';
}

final class AuthStorageError extends AuthError {
  const AuthStorageError({this.cause});
  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureStorage;

  @override
  String toString() => 'AuthStorageError(cause: $cause)';
}

final class AuthUnknownError extends AuthError {
  const AuthUnknownError({this.cause});
  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureUnknown;

  @override
  String toString() => 'AuthUnknownError(cause: $cause)';
}
