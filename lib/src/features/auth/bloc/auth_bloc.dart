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
    on<AuthFlowResetRequested>(_onFlowResetRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthSubmitting(email: event.email));

    try {
      final result = await _authRepository.signIn(
        AuthCredentialsDto(email: event.email, password: event.password),
      );

      switch (result) {
        case AuthSuccess():
          emit(AuthFlowSuccess(email: event.email));
        case AuthOtpRequiredResult(:final email):
          emit(AuthOtpRequired(email: email));
      }
    } on Object catch (error) {
      emit(
        AuthFlowFailure(failure: _mapFailure(error), email: event.email, message: error.toString()),
      );
    }
  }

  Future<void> _onOtpSubmitted(AuthOtpSubmitted event, Emitter<AuthState> emit) async {
    switch (state) {
      case AuthFlowFailure(email: null):
      case AuthIdle():
        emit(
          const AuthFlowFailure(
            failure: AuthFailure.otpChallengeMissing,
            email: null,
            message: 'email is missing',
          ),
        );
        break;
      case AuthSubmitting():
        emit(
          const AuthFlowFailure(
            failure: AuthFailure.unknown,
            email: null,
            message: 'already loading',
          ),
        );
        break;
      case AuthOtpRequired(:final email):
      case AuthFlowSuccess(:final email):
      case AuthFlowFailure(:final String email):
        emit(AuthSubmitting(email: email));

        try {
          final result = await _authRepository.verifyOtp(otp: event.otp);

          switch (result) {
            case AuthSuccess():
              emit(AuthFlowSuccess(email: email));
            case AuthOtpRequiredResult(:final email):
              emit(AuthOtpRequired(email: email));
          }
        } on Object catch (error) {
          emit(
            AuthFlowFailure(failure: _mapFailure(error), message: error.toString(), email: email),
          );
        }
    }
  }

  Future<void> _onSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthSubmitting(email: null));

    try {
      await _authRepository.signOut();
      emit(const AuthIdle());
    } on Object catch (error) {
      emit(AuthFlowFailure(failure: _mapFailure(error), message: error.toString(), email: null));
    }
  }

  Future<void> _onFlowResetRequested(AuthFlowResetRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.clearPendingOtpChallenge();
      emit(const AuthIdle());
    } on Object catch (error) {
      emit(AuthFlowFailure(failure: _mapFailure(error), message: error.toString(), email: null));
    }
  }

  AuthFailure _mapFailure(Object error) {
    if (error case AuthException(:final failure)) {
      return failure;
    }
    return AuthFailure.unknown;
  }
}
