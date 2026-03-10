import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';

abstract interface class AuthRepository {
  Session get currentSession;

  /// Session updates stream.
  ///
  /// Implementations should replay the latest known value to new subscribers.
  Stream<Session> get sessionStream;

  Future<void> initialize();

  /// Requests an OTP code to be sent to the given [email].
  Future<AuthOtpRequiredResult> requestOtp({required String email});

  /// Resends an OTP code to the given [email].
  ///
  /// May throw [AuthOtpCooldownError] or [AuthOtpMaxAttemptsError] when
  /// rate-limited.
  Future<AuthOtpRequiredResult> resendOtp({required String email});

  Future<AuthResult> verifyOtp({required String otp});

  Future<void> clearPendingOtpChallenge();

  Future<void> signOut();

  void dispose();
}

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthSessionStorage sessionStorage}) : _sessionStorage = sessionStorage;

  static const String otpChallengeId = 'otp-challenge';
  static const String validOtp = '111111';

  final AuthSessionStorage _sessionStorage;
  // BehaviorSubject replays the latest session to late subscribers (for example, blocs
  // created after app bootstrap).
  final BehaviorSubject<Session> _sessionController = BehaviorSubject<Session>.seeded(const Session.empty());

  String? _pendingOtpChallengeId;
  String? _pendingOtpEmail;

  @override
  Session get currentSession => _sessionController.value;

  @override
  Stream<Session> get sessionStream => _sessionController.stream;

  @override
  Future<void> initialize() async {
    try {
      final session = await _sessionStorage.readSession();
      // Avoid duplicate emission on initialize when seed/current already matches storage.
      if (currentSession != session) {
        _emitSession(session);
      }
    } on AuthError {
      rethrow;
    } on Object catch (e) {
      throw AuthUnknownError(cause: e);
    }
  }

  @override
  Future<AuthOtpRequiredResult> requestOtp({required String email}) async {
    _pendingOtpChallengeId = otpChallengeId;
    _pendingOtpEmail = email;
    return AuthOtpRequiredResult(challengeId: otpChallengeId, email: email);
  }

  @override
  Future<AuthOtpRequiredResult> resendOtp({required String email}) async {
    _pendingOtpChallengeId = otpChallengeId;
    _pendingOtpEmail = email;
    return AuthOtpRequiredResult(challengeId: otpChallengeId, email: email);
  }

  @override
  Future<AuthResult> verifyOtp({required String otp}) async {
    final pendingChallengeId = _pendingOtpChallengeId;
    final pendingEmail = _pendingOtpEmail;

    if (pendingChallengeId == null || pendingEmail == null) {
      throw const AuthOtpChallengeMissingError();
    }

    if (otp != validOtp) {
      throw const AuthInvalidOtpError();
    }

    final session = _buildDummySession(email: pendingEmail);
    final user = _buildDummyUser(email: pendingEmail);

    try {
      await _sessionStorage.writeSession(session);
      _emitSession(session);
      _pendingOtpChallengeId = null;
      _pendingOtpEmail = null;
      return AuthSuccess(session: session, user: user);
    } on AuthError {
      rethrow;
    } on Object catch (e) {
      throw AuthUnknownError(cause: e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _sessionStorage.deleteSession();
      _emitSession(const Session.empty());
      await clearPendingOtpChallenge();
    } on AuthError {
      rethrow;
    } on Object catch (e) {
      throw AuthUnknownError(cause: e);
    }
  }

  @override
  Future<void> clearPendingOtpChallenge() async {
    _pendingOtpChallengeId = null;
    _pendingOtpEmail = null;
  }

  @override
  void dispose() {
    _sessionController.close();
  }

  void _emitSession(Session session) {
    if (!_sessionController.isClosed) {
      _sessionController.add(session);
    }
  }

  Session _buildDummySession({required String email}) {
    final normalized = email.trim().toLowerCase().replaceAll('@', '_at_');
    return Session(accessToken: 'access_token_$normalized', refreshToken: 'refresh_token_$normalized');
  }

  UserDto _buildDummyUser({required String email}) {
    final localPart = email.split('@').first;
    final normalizedUsername = localPart.isEmpty ? 'user' : localPart;
    final capitalizedName = normalizedUsername.isEmpty
        ? 'User'
        : '${normalizedUsername[0].toUpperCase()}${normalizedUsername.substring(1)}';

    return UserDto(
      profilePicture: 'https://example.com/avatar/$normalizedUsername.png',
      username: normalizedUsername,
      name: capitalizedName,
    );
  }
}
