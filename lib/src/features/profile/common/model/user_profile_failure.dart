import 'package:pauza/src/core/localization/l10n.dart';

enum UserProfileFailureCode implements Localizable {
  unauthorized,
  forbidden,
  network,
  storage,
  usernameTaken,
  validation,
  cancelled,
  unknown;

  @override
  String localize(AppLocalizations localizations) {
    return switch (this) {
      UserProfileFailureCode.usernameTaken => localizations.profileEditUsernameTakenError,
      UserProfileFailureCode.validation => localizations.profileEditValidationError,
      UserProfileFailureCode.network => localizations.profileEditNetworkError,
      UserProfileFailureCode.unauthorized || UserProfileFailureCode.forbidden => localizations.errorTitle,
      _ => localizations.errorTitle,
    };
  }
}

final class UserProfileException implements Exception {
  const UserProfileException({required this.code, this.message});

  final UserProfileFailureCode code;
  final String? message;

  @override
  String toString() {
    return 'UserProfileException(code: $code, message: $message)';
  }
}
