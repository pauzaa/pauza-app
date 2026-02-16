import 'dart:async';

import 'package:pauza/src/features/auth/common/model/auth_credentials_dto.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/common/model/user_dto.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';

abstract interface class AuthRepository {
  Session get currentSession;

  Stream<Session> get sessionStream;

  Future<void> initialize();

  Future<AuthResult> signIn(AuthCredentialsDto credentials);

  Future<AuthResult> verifyOtp({
    required String challengeId,
    required String otp,
  });

  Future<void> signOut();

  void dispose();
}

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthSessionStorage sessionStorage})
    : _sessionStorage = sessionStorage;

  static const String invalidCredentialsEmail = 'wrong@credentials.com';
  static const String otpRequiredEmail = 'new@account.com';
  static const String otpChallengeId = 'otp-new-account';
  static const String validOtp = '111111';

  final AuthSessionStorage _sessionStorage;
  final StreamController<Session> _tokenController =
      StreamController<Session>.broadcast();

  Session _currentSession = const Session.empty();
  String? _pendingOtpChallengeId;
  String? _pendingOtpEmail;

  @override
  Session get currentSession => _currentSession;

  @override
  Stream<Session> get sessionStream => _tokenController.stream;

  @override
  Future<void> initialize() async {
    try {
      final session = await _sessionStorage.readSession();
      _emitSession(session);
    } on AuthException {
      rethrow;
    } on Object {
      throw const AuthException(failure: AuthFailure.unknown);
    }
  }

  @override
  Future<AuthResult> signIn(AuthCredentialsDto credentials) async {
    if (credentials.email == invalidCredentialsEmail) {
      throw const AuthException(failure: AuthFailure.invalidCredentials);
    }

    if (credentials.email == otpRequiredEmail) {
      _pendingOtpChallengeId = otpChallengeId;
      _pendingOtpEmail = credentials.email;
      return const AuthOtpRequiredResult(
        challengeId: otpChallengeId,
        email: otpRequiredEmail,
      );
    }

    final session = _buildDummySession(email: credentials.email);
    final user = _buildDummyUser(email: credentials.email);

    try {
      await _sessionStorage.writeSession(session);
      _emitSession(session);
      return AuthSuccess(session: session, user: user);
    } on AuthException {
      rethrow;
    } on Object {
      throw const AuthException(failure: AuthFailure.unknown);
    }
  }

  @override
  Future<AuthResult> verifyOtp({
    required String challengeId,
    required String otp,
  }) async {
    final pendingChallengeId = _pendingOtpChallengeId;
    final pendingEmail = _pendingOtpEmail;

    if (pendingChallengeId == null || pendingEmail == null) {
      throw const AuthException(failure: AuthFailure.otpChallengeMissing);
    }

    if (challengeId != pendingChallengeId) {
      throw const AuthException(failure: AuthFailure.otpChallengeMissing);
    }

    if (otp != validOtp) {
      throw const AuthException(failure: AuthFailure.invalidOtp);
    }

    final session = _buildDummySession(email: pendingEmail);
    final user = _buildDummyUser(email: pendingEmail);

    try {
      await _sessionStorage.writeSession(session);
      _emitSession(session);
      _pendingOtpChallengeId = null;
      _pendingOtpEmail = null;
      return AuthSuccess(session: session, user: user);
    } on AuthException {
      rethrow;
    } on Object {
      throw const AuthException(failure: AuthFailure.unknown);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _sessionStorage.deleteSession();
      _emitSession(const Session.empty());
      _pendingOtpChallengeId = null;
      _pendingOtpEmail = null;
    } on AuthException {
      rethrow;
    } on Object {
      throw const AuthException(failure: AuthFailure.unknown);
    }
  }

  @override
  void dispose() {
    _tokenController.close();
  }

  void _emitSession(Session session) {
    _currentSession = session;
    if (!_tokenController.isClosed) {
      _tokenController.add(session);
    }
  }

  Session _buildDummySession({required String email}) {
    final normalized = email.trim().toLowerCase().replaceAll('@', '_at_');
    return Session(
      accessToken: 'access_token_$normalized',
      refreshToken: 'refresh_token_$normalized',
    );
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
