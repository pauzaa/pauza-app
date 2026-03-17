import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/localization/l10n.dart';

sealed class AiError implements Exception, Localizable {
  const AiError();

  factory AiError.fromApiException(ApiClientException e) {
    return switch (e) {
      ApiClientAuthorizationException(:final statusCode, :final data) =>
        statusCode == 403 && _serverErrorCode(data) == 'SUBSCRIPTION_REQUIRED'
            ? const AiSubscriptionRequiredError()
            : const AiUnauthorizedError(),
      ApiClientNetworkException() => const AiNetworkError(),
      ApiClientClientException(:final statusCode, :final data) => () {
        if (statusCode == 429) return const AiRateLimitedError();
        if (_serverErrorCode(data) == 'VALIDATION_ERROR') {
          return const AiValidationError();
        }
        return AiUnknownError(e);
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

final class AiNetworkError extends AiError {
  const AiNetworkError();

  @override
  String localize(AppLocalizations localizations) => localizations.internetRequiredToast;

  @override
  String toString() => 'AiNetworkError';
}

final class AiUnauthorizedError extends AiError {
  const AiUnauthorizedError();

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'AiUnauthorizedError';
}

final class AiSubscriptionRequiredError extends AiError {
  const AiSubscriptionRequiredError();

  @override
  String localize(AppLocalizations localizations) => localizations.aiErrorSubscriptionRequired;

  @override
  String toString() => 'AiSubscriptionRequiredError';
}

final class AiRateLimitedError extends AiError {
  const AiRateLimitedError();

  @override
  String localize(AppLocalizations localizations) => localizations.aiErrorRateLimited;

  @override
  String toString() => 'AiRateLimitedError';
}

final class AiValidationError extends AiError {
  const AiValidationError();

  @override
  String localize(AppLocalizations localizations) => localizations.aiErrorGeneric;

  @override
  String toString() => 'AiValidationError';
}

final class AiUnknownError extends AiError {
  const AiUnknownError([this.cause]);

  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.aiErrorGeneric;

  @override
  String toString() => 'AiUnknownError(cause: $cause)';
}
