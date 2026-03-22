import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/model/pauza_app_error.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
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
    on<AuthEvent>(
      (event, emit) => switch (event) {
        AuthOtpRequested() => _onOtpRequested(event, emit),
        AuthOtpResendRequested() => _onOtpResendRequested(event, emit),
        AuthOtpSubmitted() => _onOtpSubmitted(event, emit),
        AuthSignOutRequested() => _onSignOutRequested(event, emit),
        AuthFlowResetRequested() => _onFlowResetRequested(event, emit),
      },
      transformer: sequential(),
    );
  }

  final AuthRepository _authRepository;
  final InternetRequiredGuard _internetRequiredGuard;

  Future<void> _onOtpRequested(AuthOtpRequested event, Emitter<AuthState> emit) async {
    if (state is AuthOtpRequired) return;

    emit(AuthSubmitting(email: event.email));

    final canProceed = await _internetRequiredGuard.canProceed();
    if (!canProceed) {
      _emitInternetRequiredFailure(emit, email: event.email);
      return;
    }

    try {
      final result = await _authRepository.requestOtp(email: event.email);
      emit(AuthOtpRequired(email: result.email));
    } on Object catch (error) {
      emit(AuthFlowFailure(error: error, email: event.email));
    }
  }

  Future<void> _onOtpResendRequested(AuthOtpResendRequested event, Emitter<AuthState> emit) async {
    final email = state.email;
    if (email == null) return;

    final previousCount = state.resentCount;

    emit(AuthResending(email: email, resentCount: previousCount));

    final canProceed = await _internetRequiredGuard.canProceed();
    if (!canProceed) {
      _emitInternetRequiredFailure(emit, email: email, resentCount: previousCount);
      return;
    }

    try {
      final result = await _authRepository.resendOtp(email: email);
      emit(AuthOtpRequired(email: result.email, resentCount: previousCount + 1));
    } on Object catch (error) {
      emit(AuthFlowFailure(error: error, email: email, resentCount: previousCount));
    }
  }

  Future<void> _onOtpSubmitted(AuthOtpSubmitted event, Emitter<AuthState> emit) async {
    switch (state) {
      case AuthFlowFailure(email: null):
      case AuthIdle():
        emit(const AuthFlowFailure(error: AuthOtpChallengeMissingError(), email: null));
      case AuthSubmitting(:final email):
        emit(
          AuthFlowFailure(
            error: const AuthUnknownError(cause: 'already loading'),
            email: email,
          ),
        );
      case AuthResending(:final email, :final resentCount):
        emit(
          AuthFlowFailure(
            error: const AuthUnknownError(cause: 'resend in progress'),
            email: email,
            resentCount: resentCount,
          ),
        );
      case AuthResetting():
      case AuthFlowSuccess():
        break;
      case AuthOtpRequired(:final email, :final resentCount):
      case AuthFlowFailure(:final String email, :final resentCount):
        await _verifyOtp(emit, email: email, otp: event.otp, resentCount: resentCount);
    }
  }

  Future<void> _verifyOtp(
    Emitter<AuthState> emit, {
    required String email,
    required String otp,
    int resentCount = 0,
  }) async {
    emit(AuthSubmitting(email: email));

    final canProceed = await _internetRequiredGuard.canProceed();
    if (!canProceed) {
      _emitInternetRequiredFailure(emit, email: email, resentCount: resentCount);
      return;
    }

    try {
      final result = await _authRepository.verifyOtp(otp: otp);

      switch (result) {
        case AuthSuccess():
          emit(AuthFlowSuccess(email: email));
        case AuthOtpRequiredResult(:final email):
          emit(AuthOtpRequired(email: email, resentCount: resentCount));
      }
    } on Object catch (error) {
      emit(AuthFlowFailure(error: error, email: email, resentCount: resentCount));
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
    if (state is AuthIdle) return;

    // Capture OTP context before resetting so the email header and resend
    // can still recover if clearPendingOtpChallenge() throws.
    final previousEmail = state.email;

    emit(const AuthResetting());

    try {
      await _authRepository.clearPendingOtpChallenge();
      emit(const AuthIdle());
    } on Object catch (error) {
      emit(AuthFlowFailure(error: error, email: previousEmail));
    }
  }

  void _emitInternetRequiredFailure(Emitter<AuthState> emit, {required String? email, int resentCount = 0}) {
    emit(AuthFlowFailure(error: const PauzaInternetUnavailableError(), email: email, resentCount: resentCount));
  }
}
