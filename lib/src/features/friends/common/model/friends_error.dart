import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/localization/l10n.dart';

sealed class FriendsError implements Exception, Localizable {
  const FriendsError();

  factory FriendsError.fromApiException(ApiClientException e) {
    return switch (e) {
      ApiClientAuthorizationException(:final statusCode, :final data) =>
        statusCode == 403 &&
                _serverErrorCode(data) == 'SUBSCRIPTION_REQUIRED'
            ? const FriendsSubscriptionRequiredError()
            : const FriendsUnauthorizedError(),
      ApiClientNetworkException() => const FriendsNetworkError(),
      ApiClientClientException(:final statusCode, :final data) => () {
          if (statusCode == 409) return const FriendsConflictError();
          if (statusCode == 404) return const FriendsNotFoundError();
          if (_serverErrorCode(data) == 'VALIDATION_ERROR') {
            return const FriendsValidationError();
          }
          return FriendsUnknownError(e);
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

final class FriendsUnauthorizedError extends FriendsError {
  const FriendsUnauthorizedError();

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'FriendsUnauthorizedError';
}

final class FriendsSubscriptionRequiredError extends FriendsError {
  const FriendsSubscriptionRequiredError();

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'FriendsSubscriptionRequiredError';
}

final class FriendsConflictError extends FriendsError {
  const FriendsConflictError();

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'FriendsConflictError';
}

final class FriendsValidationError extends FriendsError {
  const FriendsValidationError();

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'FriendsValidationError';
}

final class FriendsNotFoundError extends FriendsError {
  const FriendsNotFoundError();

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'FriendsNotFoundError';
}

final class FriendsNetworkError extends FriendsError {
  const FriendsNetworkError();

  @override
  String localize(AppLocalizations localizations) =>
      localizations.internetRequiredToast;

  @override
  String toString() => 'FriendsNetworkError';
}

final class FriendsUnknownError extends FriendsError {
  const FriendsUnknownError([this.cause]);

  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'FriendsUnknownError(cause: $cause)';
}
