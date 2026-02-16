import 'package:flutter/foundation.dart';

@immutable
final class AuthCredentialsDto {
  const AuthCredentialsDto({required this.email, required this.password});

  final String email;
  final String password;

  @override
  String toString() {
    return 'AuthCredentialsDto(email: $email, password: <redacted>)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AuthCredentialsDto &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode => Object.hash(email, password);
}
