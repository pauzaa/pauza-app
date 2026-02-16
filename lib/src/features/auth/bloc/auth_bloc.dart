import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/auth/common/model/auth_credentials_dto.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthIdle()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previous = state;
    emit(AuthSubmitting(previous: previous));

    try {
      final result = await _authRepository.signIn(
        AuthCredentialsDto(email: event.email, password: event.password),
      );

      switch (result) {
        case AuthSuccess():
          emit(const AuthFlowSuccess());
        case AuthOtpRequiredResult(:final challengeId, :final email):
          emit(AuthOtpRequired(challengeId: challengeId, email: email));
      }
    } on Object catch (error) {
      emit(
        AuthFlowFailure(
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
    emit(AuthSubmitting(previous: previous));

    if (previous is! AuthOtpRequired) {
      emit(
        const AuthFlowFailure(
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
        case AuthSuccess():
          emit(const AuthFlowSuccess());
        case AuthOtpRequiredResult(:final challengeId, :final email):
          emit(AuthOtpRequired(challengeId: challengeId, email: email));
      }
    } on Object catch (error) {
      emit(
        AuthFlowFailure(
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
    emit(AuthSubmitting(previous: previous));

    try {
      await _authRepository.signOut();
      emit(const AuthIdle());
    } on Object catch (error) {
      emit(
        AuthFlowFailure(
          failure: _mapFailure(error),
          message: error.toString(),
          previous: previous,
        ),
      );
    }
  }

  AuthFailure _mapFailure(Object error) {
    if (error case AuthException(:final failure)) {
      return failure;
    }
    return AuthFailure.unknown;
  }
}
