part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthIdle extends AuthState {
  const AuthIdle();
}

final class AuthSubmitting extends AuthState {
  const AuthSubmitting({this.previous});

  final AuthState? previous;

  @override
  List<Object?> get props => <Object?>[previous];
}

final class AuthOtpRequired extends AuthState {
  const AuthOtpRequired({required this.challengeId, required this.email});

  final String challengeId;
  final String email;

  @override
  List<Object?> get props => <Object?>[challengeId, email];
}

final class AuthFlowSuccess extends AuthState {
  const AuthFlowSuccess();
}

final class AuthFlowFailure extends AuthState {
  const AuthFlowFailure({required this.failure, this.message, this.previous});

  final AuthFailure failure;
  final String? message;
  final AuthState? previous;

  @override
  List<Object?> get props => <Object?>[failure, message, previous];
}
