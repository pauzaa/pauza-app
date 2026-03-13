import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/localization/l10n.dart';

sealed class SyncError implements Exception, Localizable {
  const SyncError();

  factory SyncError.fromApiException(ApiClientException e) {
    return switch (e) {
      ApiClientAuthorizationException() => const SyncUnauthorizedError(),
      ApiClientNetworkException() => const SyncNetworkError(),
      ApiClientClientException(:final data) =>
        _serverErrorCode(data) == 'VALIDATION_ERROR'
            ? const SyncValidationError()
            : SyncUnknownError(e),
    };
  }

  static String? _serverErrorCode(Object? data) {
    if (data is! Map<String, Object?>) return null;
    final error = data['error'];
    if (error is! Map<String, Object?>) return null;
    return error['code'] as String?;
  }
}

final class SyncNetworkError extends SyncError {
  const SyncNetworkError();

  @override
  String localize(AppLocalizations localizations) =>
      localizations.internetRequiredToast;

  @override
  String toString() => 'SyncNetworkError';
}

final class SyncUnauthorizedError extends SyncError {
  const SyncUnauthorizedError();

  @override
  String localize(AppLocalizations localizations) =>
      localizations.errorTitle;

  @override
  String toString() => 'SyncUnauthorizedError';
}

final class SyncValidationError extends SyncError {
  const SyncValidationError();

  @override
  String localize(AppLocalizations localizations) =>
      localizations.errorTitle;

  @override
  String toString() => 'SyncValidationError';
}

final class SyncUnknownError extends SyncError {
  const SyncUnknownError([this.cause]);

  final Object? cause;

  @override
  String localize(AppLocalizations localizations) =>
      localizations.errorTitle;

  @override
  String toString() => 'SyncUnknownError(cause: $cause)';
}
