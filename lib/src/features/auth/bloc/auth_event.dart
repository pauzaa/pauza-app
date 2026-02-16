part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => <Object?>[email, password];
}

final class AuthOtpSubmitted extends AuthEvent {
  const AuthOtpSubmitted({required this.otp});

  final String otp;

  @override
  List<Object?> get props => <Object?>[otp];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthSessionChanged extends AuthEvent {
  const AuthSessionChanged({required this.session});

  final Session session;

  @override
  List<Object?> get props => <Object?>[session];
}
