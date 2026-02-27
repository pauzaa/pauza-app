import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/model/pauza_app_error.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
import 'package:pauza/src/features/auth/common/model/auth_credentials_dto.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository, required InternetRequiredGuard internetRequiredGuard})
    : _authRepository = authRepository,
      _internetRequiredGuard = internetRequiredGuard,
      super(const AuthIdle()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthFlowResetRequested>(_onFlowResetRequested);
  }

  final AuthRepository _authRepository;
  final InternetRequiredGuard _internetRequiredGuard;

  Future<void> _onSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    final canProceed = await _internetRequiredGuard.canProceed();
    if (!canProceed) {
      _emitInternetRequiredFailure(emit, email: event.email);
      return;
    }

    emit(AuthSubmitting(email: event.email));

    try {
      final result = await _authRepository.signIn(AuthCredentialsDto(email: event.email, password: event.password));

      switch (result) {
        case AuthSuccess():
          emit(AuthFlowSuccess(email: event.email));
        case AuthOtpRequiredResult(:final email):
          emit(AuthOtpRequired(email: email));
      }
    } on Object catch (error) {
      emit(AuthFlowFailure(error: error, email: event.email));
    }
  }

  Future<void> _onOtpSubmitted(AuthOtpSubmitted event, Emitter<AuthState> emit) async {
    switch (state) {
      case AuthFlowFailure(email: null):
      case AuthIdle():
        emit(const AuthFlowFailure(error: AuthException(failure: AuthFailure.otpChallengeMissing), email: null));
        break;
      case AuthSubmitting():
        emit(
          const AuthFlowFailure(
            error: AuthException(failure: AuthFailure.unknown, message: 'already loading'),
            email: null,
          ),
        );
        break;
      case AuthOtpRequired(:final email):
      case AuthFlowSuccess(:final email):
      case AuthFlowFailure(:final String email):
        emit(AuthSubmitting(email: email));
        final canProceed = await _internetRequiredGuard.canProceed();
        if (!canProceed) {
          _emitInternetRequiredFailure(emit, email: email);
          return;
        }

        try {
          final result = await _authRepository.verifyOtp(otp: event.otp);

          switch (result) {
            case AuthSuccess():
              emit(AuthFlowSuccess(email: email));
            case AuthOtpRequiredResult(:final email):
              emit(AuthOtpRequired(email: email));
          }
        } on Object catch (error) {
          emit(AuthFlowFailure(error: error, email: email));
        }
    }
  }

  Future<void> _onSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthSubmitting(email: null));

    try {
      await _authRepository.signOut();
      emit(const AuthIdle());
    } on Object catch (error) {
      emit(AuthFlowFailure(error: error, email: null));
    }
  }

  Future<void> _onFlowResetRequested(AuthFlowResetRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.clearPendingOtpChallenge();
      emit(const AuthIdle());
    } on Object catch (error) {
      emit(AuthFlowFailure(error: error, email: null));
    }
  }

  void _emitInternetRequiredFailure(Emitter<AuthState> emit, {required String? email}) {
    emit(AuthFlowFailure(error: PauzaAppError.internetUnavailable, email: email));
  }
}
