part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading({this.previous});

  final AuthState? previous;

  @override
  List<Object?> get props => <Object?>[previous];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthOtpRequired extends AuthState {
  const AuthOtpRequired({required this.challengeId, required this.email});

  final String challengeId;
  final String email;

  @override
  List<Object?> get props => <Object?>[challengeId, email];
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.session, this.user});

  final Session session;
  final UserDto? user;

  @override
  List<Object?> get props => <Object?>[session, user];
}

final class AuthFailureState extends AuthState {
  const AuthFailureState({required this.failure, this.message, this.previous});

  final AuthFailure failure;
  final String? message;
  final AuthState? previous;

  @override
  List<Object?> get props => <Object?>[failure, message, previous];
}
