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
  const AuthSubmitting({required this.email});

  final String? email;

  @override
  List<Object?> get props => <Object?>[email];
}

final class AuthOtpRequired extends AuthState {
  const AuthOtpRequired({required this.email});

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

final class AuthFlowSuccess extends AuthState {
  const AuthFlowSuccess({required this.email});
  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

final class AuthFlowFailure extends AuthState {
  const AuthFlowFailure({required this.error, required this.email});

  final Object error;
  final String? email;

  @override
  List<Object?> get props => <Object?>[error, email];
}
