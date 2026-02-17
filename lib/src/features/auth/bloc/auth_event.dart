part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const <Object?>[];
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

final class AuthFlowResetRequested extends AuthEvent {
  const AuthFlowResetRequested();
}
