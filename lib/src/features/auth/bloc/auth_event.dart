part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthOtpRequested extends AuthEvent {
  const AuthOtpRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

final class AuthOtpSubmitted extends AuthEvent {
  const AuthOtpSubmitted({required this.otp});

  final String otp;

  @override
  List<Object?> get props => <Object?>[otp];
}

final class AuthOtpResendRequested extends AuthEvent {
  const AuthOtpResendRequested();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthFlowResetRequested extends AuthEvent {
  const AuthFlowResetRequested();
}
