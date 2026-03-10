part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  String? get email => switch (this) {
    AuthSubmitting(:final email) => email,
    AuthOtpRequired(:final email) => email,
    AuthFlowSuccess(:final email) => email,
    AuthResending(:final email) => email,
    AuthFlowFailure(:final email) => email,
    AuthIdle() || AuthResetting() => null,
  };

  int get resentCount => switch (this) {
    AuthOtpRequired(:final resentCount) => resentCount,
    AuthResending(:final resentCount) => resentCount,
    AuthFlowFailure(:final resentCount) => resentCount,
    AuthIdle() || AuthSubmitting() || AuthFlowSuccess() || AuthResetting() => 0,
  };

  bool get isBusy => switch (this) {
    AuthSubmitting() || AuthResending() || AuthResetting() => true,
    AuthIdle() || AuthOtpRequired() || AuthFlowSuccess() || AuthFlowFailure() => false,
  };

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthIdle extends AuthState {
  const AuthIdle();
}

final class AuthSubmitting extends AuthState {
  const AuthSubmitting({required this.email});

  @override
  final String? email;

  @override
  List<Object?> get props => <Object?>[email];
}

final class AuthOtpRequired extends AuthState {
  const AuthOtpRequired({required this.email, this.resentCount = 0});

  @override
  final String email;
  @override
  final int resentCount;

  bool get resent => resentCount > 0;

  @override
  List<Object?> get props => <Object?>[email, resentCount];
}

final class AuthFlowSuccess extends AuthState {
  const AuthFlowSuccess({required this.email});

  @override
  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

final class AuthResending extends AuthState {
  const AuthResending({required this.email, required this.resentCount});

  @override
  final String email;
  @override
  final int resentCount;

  @override
  List<Object?> get props => <Object?>[email, resentCount];
}

final class AuthResetting extends AuthState {
  const AuthResetting();
}

final class AuthFlowFailure extends AuthState {
  const AuthFlowFailure({required this.error, required this.email, this.resentCount = 0});

  final Object error;
  @override
  final String? email;
  @override
  final int resentCount;

  @override
  List<Object?> get props => <Object?>[error, email, resentCount];
}
