import 'package:pauza/src/core/localization/l10n.dart';

sealed class FriendsError implements Exception, Localizable {
  const FriendsError();
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
