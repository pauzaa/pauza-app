import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/auth/common/model/auth_credentials_dto.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/common/model/user_dto.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthSessionChanged>(_onSessionChanged);

    _sessionSubscription = _authRepository.sessionStream.listen((session) {
      add(AuthSessionChanged(session: session));
    });
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<Session> _sessionSubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading(previous: state));
    try {
      await _authRepository.initialize();
    } on Object catch (error) {
      emit(
        AuthFailureState(
          failure: _mapFailure(error),
          message: error.toString(),
          previous: state,
        ),
      );
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previous = state;
    emit(AuthLoading(previous: previous));

    try {
      final result = await _authRepository.signIn(
        AuthCredentialsDto(email: event.email, password: event.password),
      );

      switch (result) {
        case AuthSuccess(:final session, :final user):
          emit(AuthAuthenticated(session: session, user: user));
        case AuthOtpRequiredResult(:final challengeId, :final email):
          emit(AuthOtpRequired(challengeId: challengeId, email: email));
      }
    } on Object catch (error) {
      emit(
        AuthFailureState(
          failure: _mapFailure(error),
          message: error.toString(),
          previous: previous,
        ),
      );
    }
  }

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final previous = state;
    emit(AuthLoading(previous: previous));

    if (previous is! AuthOtpRequired) {
      emit(
        const AuthFailureState(
          failure: AuthFailure.otpChallengeMissing,
          message: 'OTP challenge is missing.',
        ),
      );
      return;
    }

    try {
      final result = await _authRepository.verifyOtp(
        challengeId: previous.challengeId,
        otp: event.otp,
      );

      switch (result) {
        case AuthSuccess(:final session, :final user):
          emit(AuthAuthenticated(session: session, user: user));
        case AuthOtpRequiredResult(:final challengeId, :final email):
          emit(AuthOtpRequired(challengeId: challengeId, email: email));
      }
    } on Object catch (error) {
      emit(
        AuthFailureState(
          failure: _mapFailure(error),
          message: error.toString(),
          previous: previous,
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previous = state;
    emit(AuthLoading(previous: previous));

    try {
      await _authRepository.signOut();
    } on Object catch (error) {
      emit(
        AuthFailureState(
          failure: _mapFailure(error),
          message: error.toString(),
          previous: previous,
        ),
      );
    }
  }

  void _onSessionChanged(AuthSessionChanged event, Emitter<AuthState> emit) {
    if (event.session.isAuthenticated) {
      final currentState = state;
      final user = currentState is AuthAuthenticated ? currentState.user : null;
      emit(AuthAuthenticated(session: event.session, user: user));
      return;
    }
    emit(const AuthUnauthenticated());
  }

  AuthFailure _mapFailure(Object error) {
    if (error case AuthException(:final failure)) {
      return failure;
    }
    return AuthFailure.unknown;
  }

  @override
  Future<void> close() async {
    await _sessionSubscription.cancel();
    return super.close();
  }
}
