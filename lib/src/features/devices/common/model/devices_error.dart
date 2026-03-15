import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/localization/l10n.dart';

sealed class DevicesError implements Exception, Localizable {
  const DevicesError();

  factory DevicesError.fromApiException(ApiClientException e) {
    return switch (e) {
      ApiClientAuthorizationException() => const DevicesUnauthorizedError(),
      ApiClientNetworkException() => const DevicesNetworkError(),
      ApiClientClientException(:final data) =>
        _serverErrorCode(data) == 'VALIDATION_ERROR'
            ? const DevicesValidationError()
            : DevicesUnknownError(e),
    };
  }

  static String? _serverErrorCode(Object? data) {
    if (data is! Map<String, Object?>) return null;
    final error = data['error'];
    if (error is! Map<String, Object?>) return null;
    return error['code'] as String?;
  }
}

final class DevicesNetworkError extends DevicesError {
  const DevicesNetworkError();

  @override
  String localize(AppLocalizations localizations) =>
      localizations.internetRequiredToast;

  @override
  String toString() => 'DevicesNetworkError';
}

final class DevicesUnauthorizedError extends DevicesError {
  const DevicesUnauthorizedError();

  @override
  String localize(AppLocalizations localizations) =>
      localizations.errorTitle;

  @override
  String toString() => 'DevicesUnauthorizedError';
}

final class DevicesValidationError extends DevicesError {
  const DevicesValidationError();

  @override
  String localize(AppLocalizations localizations) =>
      localizations.errorTitle;

  @override
  String toString() => 'DevicesValidationError';
}

final class DevicesUnknownError extends DevicesError {
  const DevicesUnknownError([this.cause]);

  final Object? cause;

  @override
  String localize(AppLocalizations localizations) =>
      localizations.errorTitle;

  @override
  String toString() => 'DevicesUnknownError(cause: $cause)';
}
