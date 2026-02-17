import 'package:pauza/src/core/localization/l10n.dart';

enum AuthFailure {
  invalidCredentials,
  invalidOtp,
  otpChallengeMissing,
  storageFailure,
  unknown;

  String localizeString(AppLocalizations l10n) {
    return switch (this) {
      AuthFailure.invalidCredentials => l10n.authFailureInvalidCredentials,
      AuthFailure.invalidOtp => l10n.authFailureInvalidOtp,
      AuthFailure.otpChallengeMissing => l10n.authFailureOtpChallengeMissing,
      AuthFailure.storageFailure => l10n.authFailureStorage,
      AuthFailure.unknown => l10n.authFailureUnknown,
    };
  }
}

final class AuthException implements Exception {
  const AuthException({required this.failure, this.message});

  final AuthFailure failure;
  final String? message;

  @override
  String toString() {
    return 'AuthException(failure: $failure, message: $message)';
  }
}
