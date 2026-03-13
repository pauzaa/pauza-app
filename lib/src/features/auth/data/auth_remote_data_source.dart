import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required Uri baseUrl,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl,
        _httpClient = httpClient ?? http.Client();

  final Uri _baseUrl;
  final http.Client _httpClient;

  static const _jsonHeaders = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // ---- public API ---------------------------------------------------------

  @override
  Future<void> start({required String email}) async {
    await _post(
      '/api/v1/auth/start',
      body: <String, Object?>{'email': email},
      errorContext: _ErrorContext.start,
    );
  }

  @override
  Future<AuthVerifyResponse> verify({
    required String email,
    required String otp,
  }) async {
    final json = await _post(
      '/api/v1/auth/verify',
      body: <String, Object?>{'email': email, 'otp': otp},
      errorContext: _ErrorContext.verify,
    );

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
    final json = await _post(
      '/api/v1/auth/refresh',
      body: <String, Object?>{'refresh_token': refreshToken},
      errorContext: _ErrorContext.refresh,
    );

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

  // ---- helpers ------------------------------------------------------------

  Future<Map<String, Object?>> _post(
    String path, {
    required Map<String, Object?> body,
    required _ErrorContext errorContext,
  }) async {
    final uri = _baseUrl.replace(path: path);

    final http.Response response;
    try {
      response = await _httpClient.post(
        uri,
        headers: _jsonHeaders,
        body: jsonEncode(body),
      );
    } on Object catch (e) {
      throw AuthNetworkError(cause: e);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _decodeJson(response.body);
    }

    _throwForStatus(response, errorContext);
  }

  Map<String, Object?> _decodeJson(String body) {
    if (body.isEmpty) return <String, Object?>{};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, Object?>) return decoded;
      return <String, Object?>{};
    } on Object {
      return <String, Object?>{};
    }
  }

  Never _throwForStatus(http.Response response, _ErrorContext errorContext) {
    final json = _decodeJson(response.body);
    final errorMap = json['error'] as Map<String, Object?>?;
    final errorCode = errorMap?['code'] as String?;
    final errorMessage = errorMap?['message'] as String?;

    switch (response.statusCode) {
      case 401:
        if (errorContext == _ErrorContext.refresh) {
          throw AuthRefreshFailedError(cause: errorMessage);
        }
        throw const AuthInvalidOtpError();

      case 422:
        final details = errorMap?['details'] as Map<String, Object?>?;
        final fields = details?['fields'] as Map<String, Object?>?;
        final fieldMessage = fields?.values.firstOrNull?.toString();
        throw AuthValidationError(message: fieldMessage ?? errorMessage);

      case 429:
        final retryAfterSeconds = int.tryParse(
          response.headers['retry-after'] ?? '',
        );
        throw AuthOtpCooldownError(
          retryAfter: retryAfterSeconds != null
              ? Duration(seconds: retryAfterSeconds)
              : null,
        );

      case >= 500:
        throw AuthNetworkError(cause: errorMessage ?? errorCode);

      default:
        throw AuthUnknownError(
          cause: errorMessage ?? 'HTTP ${response.statusCode}',
        );
    }
  }
}

enum _ErrorContext { start, verify, refresh }
