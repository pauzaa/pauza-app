import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_remote_data_source.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';

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

  /// Attempts to refresh the current session using the stored refresh token.
  ///
  /// Returns the new access token on success, or `null` if the refresh failed
  /// (in which case the user is automatically signed out).
  Future<String?> refreshSession();

  Future<void> clearPendingOtpChallenge();

  Future<void> signOut();

  /// Clears the local session without any network calls.
  ///
  /// Used when the auth middleware detects an irrecoverable auth failure
  /// (e.g. retry after token refresh also returns 401).
  Future<void> forceLocalSignOut();

  void dispose();
}

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthSessionStorage sessionStorage,
    Future<void> Function()? onSignOutCleanup,
  }) : _remoteDataSource = remoteDataSource,
       _sessionStorage = sessionStorage,
       _onSignOutCleanup = onSignOutCleanup;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthSessionStorage _sessionStorage;
  final Future<void> Function()? _onSignOutCleanup;

  final BehaviorSubject<Session> _sessionController = BehaviorSubject<Session>.seeded(const Session.empty());

  String? _pendingOtpEmail;

  /// In-flight refresh future used to deduplicate concurrent refresh calls.
  Future<String?>? _pendingRefresh;

  @override
  Session get currentSession => _sessionController.value;

  @override
  Stream<Session> get sessionStream => _sessionController.stream;

  @override
  Future<void> initialize() async {
    try {
      final session = await _sessionStorage.readSession();
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
    try {
      await _remoteDataSource.start(email: email);
    } on AuthError {
      rethrow;
    } on Object catch (e) {
      throw AuthUnknownError(cause: e);
    }

    _pendingOtpEmail = email;
    return AuthOtpRequiredResult(challengeId: '', email: email);
  }

  @override
  Future<AuthOtpRequiredResult> resendOtp({required String email}) => requestOtp(email: email);

  @override
  Future<AuthResult> verifyOtp({required String otp}) async {
    final pendingEmail = _pendingOtpEmail;
    if (pendingEmail == null) {
      throw const AuthOtpChallengeMissingError();
    }

    try {
      final response = await _remoteDataSource.verify(email: pendingEmail, otp: otp);

      final session = Session(accessToken: response.accessToken, refreshToken: response.refreshToken);
      final user = UserDto.fromJson(response.userJson);

      await _sessionStorage.writeSession(session);
      _emitSession(session);
      _pendingOtpEmail = null;

      return AuthSuccess(session: session, user: user);
    } on AuthError {
      rethrow;
    } on Object catch (e) {
      throw AuthUnknownError(cause: e);
    }
  }

  @override
  Future<String?> refreshSession() => _pendingRefresh ??= _doRefresh().whenComplete(() => _pendingRefresh = null);

  @override
  Future<void> signOut() async {
    // Best-effort remote token revocation -- offline logout must still work.
    try {
      await _remoteDataSource.logout();
    } on Object {
      // Ignored intentionally.
    }

    // Critical path: clear session state first so the user is always
    // redirected to login, even if cleanup steps throw.
    try {
      await _sessionStorage.deleteSession();
    } on Object {
      // Best-effort; stale token on disk will fail refresh on next launch.
    }
    _emitSession(const Session.empty());
    _pendingOtpEmail = null;

    // Best-effort cleanup — must never prevent sign-out.
    try {
      await _onSignOutCleanup?.call();
    } on Object {
      // Cleanup failure is acceptable; session is already invalidated.
    }
  }

  @override
  Future<void> forceLocalSignOut() async {
    // No remote calls — safe to call from the auth middleware without
    // risking circular API requests.
    try {
      await _sessionStorage.deleteSession();
    } on Object {
      // Best-effort.
    }
    _emitSession(const Session.empty());
    _pendingOtpEmail = null;

    try {
      await _onSignOutCleanup?.call();
    } on Object {
      // Best-effort.
    }
  }

  @override
  Future<void> clearPendingOtpChallenge() async {
    _pendingOtpEmail = null;
  }

  @override
  void dispose() {
    _sessionController.close();
  }

  // ---- private helpers ----------------------------------------------------

  Future<String?> _doRefresh() async {
    final refreshToken = currentSession.refreshToken;
    if (refreshToken.isEmpty) return null;

    try {
      final response = await _remoteDataSource.refresh(refreshToken: refreshToken);

      final newSession = Session(accessToken: response.accessToken, refreshToken: response.refreshToken);

      await _sessionStorage.writeSession(newSession);
      _emitSession(newSession);

      return newSession.accessToken;
    } on Object {
      // Local-only cleanup — skip the remote logout call to avoid a deadlock:
      // the logout POST would trigger the auth middleware, which would call
      // refreshSession(), returning _pendingRefresh (this very future).
      //
      // Critical path first: clear session state so the auth gate fires and
      // the router redirects to login, regardless of cleanup outcome.
      try {
        await _sessionStorage.deleteSession();
      } on Object {
        // Best-effort.
      }
      _emitSession(const Session.empty());
      _pendingOtpEmail = null;

      // Best-effort cleanup — must never prevent session clearing.
      try {
        await _onSignOutCleanup?.call();
      } on Object {
        // Cleanup failure is acceptable; session is already invalidated.
      }
      return null;
    }
  }

  void _emitSession(Session session) {
    if (!_sessionController.isClosed) {
      _sessionController.add(session);
    }
  }
}
