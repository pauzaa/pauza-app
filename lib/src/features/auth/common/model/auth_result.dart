import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/common/model/user_dto.dart';

@immutable
sealed class AuthResult {
  const AuthResult();
}

final class AuthSuccess extends AuthResult {
  const AuthSuccess({required this.session, required this.user});

  final Session session;
  final UserDto user;
}

final class AuthOtpRequiredResult extends AuthResult {
  const AuthOtpRequiredResult({required this.challengeId, required this.email});

  final String challengeId;
  final String email;
}
