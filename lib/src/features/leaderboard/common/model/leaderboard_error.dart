import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/localization/l10n.dart';

sealed class LeaderboardError implements Exception, Localizable {
  const LeaderboardError();

  factory LeaderboardError.fromApiException(ApiClientException e) {
    return switch (e) {
      ApiClientAuthorizationException() =>
        const LeaderboardUnauthorizedError(),
      ApiClientNetworkException() => const LeaderboardNetworkError(),
      ApiClientClientException() => LeaderboardUnknownError(e),
    };
  }
}

final class LeaderboardUnauthorizedError extends LeaderboardError {
  const LeaderboardUnauthorizedError();

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'LeaderboardUnauthorizedError';
}

final class LeaderboardNetworkError extends LeaderboardError {
  const LeaderboardNetworkError();

  @override
  String localize(AppLocalizations localizations) =>
      localizations.internetRequiredToast;

  @override
  String toString() => 'LeaderboardNetworkError';
}

final class LeaderboardUnknownError extends LeaderboardError {
  const LeaderboardUnknownError([this.cause]);

  final Object? cause;

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;

  @override
  String toString() => 'LeaderboardUnknownError(cause: $cause)';
}
