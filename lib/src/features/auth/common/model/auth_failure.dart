import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/localization/l10n.dart';

enum AuthErrorContext { start, verify, refresh, logout }

/// Sealed hierarchy of authentication errors.
///
/// Each variant implements [Exception] and [Localizable] so that
/// error objects can be thrown, caught by type, and localized
/// without enum-code extraction.
sealed class AuthError implements Exception, Localizable {
  const AuthError();

  factory AuthError.fromApiException(ApiClientException e, {required AuthErrorContext context}) {
    return switch (e) {
      ApiClientAuthorizationException() =>
        context == AuthErrorContext.refresh
            ? AuthRefreshFailedError(cause: _serverMessage(e.data))
            : const AuthInvalidOtpError(),
      ApiClientClientException(:final statusCode, :final data, :final responseHeaders) => () {
        if (statusCode == 422) {
          final fieldMessage = _firstFieldMessage(data);
          return AuthValidationError(message: fieldMessage ?? _serverMessage(data));
        }
        if (statusCode == 429) {
          final retryAfterSeconds = int.tryParse(responseHeaders['retry-after'] ?? '');
          return AuthOtpCooldownError(
            retryAfter: retryAfterSeconds != null ? Duration(seconds: retryAfterSeconds) : null,
          );
        }
        return AuthUnknownError(cause: _serverMessage(data) ?? 'HTTP $statusCode');
      }(),
      ApiClientNetworkException() => AuthNetworkError(cause: e.message),
    };
  }

  static String? _serverMessage(Object? data) {
    if (data is! Map<String, Object?>) return null;
    final error = data['error'];
    if (error is! Map<String, Object?>) return null;
    return error['message'] as String?;
  }

  static String? _firstFieldMessage(Object? data) {
    if (data is! Map<String, Object?>) return null;
    final error = data['error'];
    if (error is! Map<String, Object?>) return null;
    final details = error['details'];
    if (details is! Map<String, Object?>) return null;
    final fields = details['fields'];
    if (fields is! Map<String, Object?>) return null;
    return fields.values.firstOrNull?.toString();
  }
}

final class AuthInvalidOtpError extends AuthError {
  const AuthInvalidOtpError();

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureInvalidOtp;

  @override
  String toString() => 'AuthInvalidOtpError';
}

final class AuthOtpMaxAttemptsError extends AuthError {
  const AuthOtpMaxAttemptsError();

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureOtpMaxAttempts;

  @override
  String toString() => 'AuthOtpMaxAttemptsError';
}

final class AuthOtpCooldownError extends AuthError {
  const AuthOtpCooldownError({this.retryAfter});

  /// Optional hint for how long the user must wait before retrying.
  final Duration? retryAfter;

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureCooldown;

  @override
  String toString() => 'AuthOtpCooldownError(retryAfter: $retryAfter)';
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

final class AuthValidationError extends AuthError {
  const AuthValidationError({this.message});
  final String? message;

  @override
  String localize(AppLocalizations localizations) => message ?? localizations.authFailureValidation;

  @override
  String toString() => 'AuthValidationError(message: $message)';
}

final class AuthRefreshFailedError extends AuthError {
  const AuthRefreshFailedError({this.cause});
  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureRefreshFailed;

  @override
  String toString() => 'AuthRefreshFailedError(cause: $cause)';
}

final class AuthNetworkError extends AuthError {
  const AuthNetworkError({this.cause});
  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureNetwork;

  @override
  String toString() => 'AuthNetworkError(cause: $cause)';
}

final class AuthUnknownError extends AuthError {
  const AuthUnknownError({this.cause});
  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.authFailureUnknown;

  @override
  String toString() => 'AuthUnknownError(cause: $cause)';
}
