import 'package:flutter/foundation.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/api_client/middleware/auth_mw.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';

// ---------------------------------------------------------------------------
// Response types
// ---------------------------------------------------------------------------

@immutable
final class AuthVerifyResponse {
  const AuthVerifyResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userJson,
  });

  final String accessToken;
  final String refreshToken;

  /// Raw user JSON from the backend, parsed by the caller into a `UserDto`.
  final Map<String, Object?> userJson;

  @override
  String toString() =>
      'AuthVerifyResponse(accessToken: <redacted>, refreshToken: <redacted>)';
}

@immutable
final class AuthRefreshResponse {
  const AuthRefreshResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  @override
  String toString() =>
      'AuthRefreshResponse(accessToken: <redacted>, refreshToken: <redacted>)';
}

// ---------------------------------------------------------------------------
// Interface
// ---------------------------------------------------------------------------

abstract interface class AuthRemoteDataSource {
  /// `POST /api/v1/auth/start` -- sends an OTP to [email].
  Future<void> start({required String email});

  /// `POST /api/v1/auth/verify` -- verifies the OTP and returns tokens + user.
  Future<AuthVerifyResponse> verify({
    required String email,
    required String otp,
  });

  /// `POST /api/v1/auth/refresh` -- exchanges [refreshToken] for a new pair.
  Future<AuthRefreshResponse> refresh({required String refreshToken});

  /// `POST /api/v1/auth/logout` -- revokes all refresh tokens for the current user.
  Future<void> logout();
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const Map<String, Object?> _skipAuthCtx = <String, Object?>{
    ApiClientAuthMiddleware.skipAuthKey: true,
  };

  // ---- public API ---------------------------------------------------------

  @override
  Future<void> start({required String email}) async {
    try {
      await _apiClient.post(
        '/api/v1/auth/start',
        body: <String, Object?>{'email': email},
        context: _skipAuthCtx,
      );
    } on ApiClientException catch (e) {
      throw AuthError.fromApiException(e, context: AuthErrorContext.start);
    }
  }

  @override
  Future<AuthVerifyResponse> verify({
    required String email,
    required String otp,
  }) async {
    final ApiClientResponse response;
    try {
      response = await _apiClient.post(
        '/api/v1/auth/verify',
        body: <String, Object?>{'email': email, 'otp': otp},
        context: _skipAuthCtx,
      );
    } on ApiClientException catch (e) {
      throw AuthError.fromApiException(e, context: AuthErrorContext.verify);
    }

    final json = response.data ?? <String, Object?>{};
    final accessToken = json['access_token'] as String?;
    final refreshToken = json['refresh_token'] as String?;
    final userJson = json['user'] as Map<String, Object?>?;

    if (accessToken == null || refreshToken == null || userJson == null) {
      throw const AuthUnknownError(cause: 'Incomplete verify response');
    }

    return AuthVerifyResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userJson: userJson,
    );
  }

  @override
  Future<AuthRefreshResponse> refresh({required String refreshToken}) async {
    final ApiClientResponse response;
    try {
      response = await _apiClient.post(
        '/api/v1/auth/refresh',
        body: <String, Object?>{'refresh_token': refreshToken},
        context: _skipAuthCtx,
      );
    } on ApiClientException catch (e) {
      throw AuthError.fromApiException(e, context: AuthErrorContext.refresh);
    }

    final json = response.data ?? <String, Object?>{};
    final newAccessToken = json['access_token'] as String?;
    final newRefreshToken = json['refresh_token'] as String?;

    if (newAccessToken == null || newRefreshToken == null) {
      throw const AuthRefreshFailedError(cause: 'Incomplete refresh response');
    }

    return AuthRefreshResponse(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('/api/v1/auth/logout');
    } on ApiClientException catch (e) {
      throw AuthError.fromApiException(e, context: AuthErrorContext.logout);
    }
  }

}
