enum UserProfileFailureCode { unauthorized, forbidden, network, storage, unknown }

final class UserProfileException implements Exception {
  const UserProfileException({required this.code, this.message});

  final UserProfileFailureCode code;
  final String? message;

  @override
  String toString() {
    return 'UserProfileException(code: $code, message: $message)';
  }
}
