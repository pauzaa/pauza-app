import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/localization/l10n.dart';

sealed class UserProfileError implements Exception, Localizable {
  const UserProfileError();

  factory UserProfileError.fromApiException(ApiClientException e) {
    return switch (e) {
      ApiClientAuthorizationException(:final statusCode) =>
        statusCode == 403 ? const UserProfileForbiddenError() : const UserProfileUnauthorizedError(),
      ApiClientNetworkException() => const UserProfileNetworkError(),
      ApiClientClientException(:final statusCode, :final data) => () {
        if (statusCode == 409) return const UserProfileUsernameTakenError();
        if (_serverErrorCode(data) == 'VALIDATION_ERROR') {
          return const UserProfileValidationError();
        }
        return UserProfileUnknownError(e);
      }(),
    };
  }

  static String? _serverErrorCode(Object? data) {
    if (data is! Map<String, Object?>) return null;
    final error = data['error'];
    if (error is! Map<String, Object?>) return null;
    return error['code'] as String?;
  }
}

final class UserProfileUnauthorizedError extends UserProfileError {
  const UserProfileUnauthorizedError();

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'UserProfileUnauthorizedError';
}

final class UserProfileForbiddenError extends UserProfileError {
  const UserProfileForbiddenError();

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'UserProfileForbiddenError';
}

final class UserProfileNetworkError extends UserProfileError {
  const UserProfileNetworkError();

  @override
  String localize(AppLocalizations localizations) => localizations.profileEditNetworkError;

  @override
  String toString() => 'UserProfileNetworkError';
}

final class UserProfileStorageError extends UserProfileError {
  const UserProfileStorageError([this.cause]);

  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'UserProfileStorageError(cause: $cause)';
}

final class UserProfileUsernameTakenError extends UserProfileError {
  const UserProfileUsernameTakenError();

  @override
  String localize(AppLocalizations localizations) => localizations.profileEditUsernameTakenError;

  @override
  String toString() => 'UserProfileUsernameTakenError';
}

final class UserProfileValidationError extends UserProfileError {
  const UserProfileValidationError();

  @override
  String localize(AppLocalizations localizations) => localizations.profileEditValidationError;

  @override
  String toString() => 'UserProfileValidationError';
}

final class UserProfileCancelledError extends UserProfileError {
  const UserProfileCancelledError();

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'UserProfileCancelledError';
}

final class UserProfileUnknownError extends UserProfileError {
  const UserProfileUnknownError([this.cause]);

  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'UserProfileUnknownError(cause: $cause)';
}
