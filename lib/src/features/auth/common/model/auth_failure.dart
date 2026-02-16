enum AuthFailure {
  invalidCredentials,
  invalidOtp,
  otpChallengeMissing,
  storageFailure,
  unknown,
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
