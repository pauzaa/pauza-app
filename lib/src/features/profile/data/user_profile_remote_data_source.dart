import 'dart:typed_data';

import 'package:http/http.dart' show MultipartFile;
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';

abstract interface class UserProfileRemoteDataSource {
  Future<UserDto> fetchMe();

  Future<UserDto> updateMe({String? name, String? username});

  Future<bool> isUsernameAvailable({required String username});

  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String filename,
  });

  Future<bool> fetchNotificationPreferences();

  Future<bool> updateNotificationPreferences({required bool pushEnabled});

  Future<bool> fetchPrivacyPreferences();

  Future<bool> updatePrivacyPreferences({required bool leaderboardVisible});
}

final class UserProfileRemoteDataSourceImpl
    implements UserProfileRemoteDataSource {
  const UserProfileRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<UserDto> fetchMe() async {
    try {
      final response = await _apiClient.get('/api/v1/me');
      return UserDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<UserDto> updateMe({String? name, String? username}) async {
    final body = <String, Object?>{};
    if (name != null) body['name'] = name;
    if (username != null) body['username'] = username;

    try {
      final response = await _apiClient.patch('/api/v1/me', body: body);
      return UserDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<bool> isUsernameAvailable({required String username}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/me/username-available',
        queryParameters: <String, Object>{'username': username},
      );
      return response.data!['available'] as bool;
    } on ApiClientException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String filename,
  }) async {
    final file = MultipartFile.fromBytes(
      'photo',
      bytes,
      filename: filename,
    );

    try {
      final response = await _apiClient.post('/api/v1/me/photo', body: file);
      return response.data!['profile_picture_url'] as String;
    } on ApiClientException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<bool> fetchNotificationPreferences() async {
    try {
      final response = await _apiClient.get(
        '/api/v1/me/notification-preferences',
      );
      return response.data!['push_enabled'] as bool;
    } on ApiClientException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<bool> updateNotificationPreferences({
    required bool pushEnabled,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/api/v1/me/notification-preferences',
        body: <String, Object?>{'push_enabled': pushEnabled},
      );
      return response.data!['push_enabled'] as bool;
    } on ApiClientException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<bool> fetchPrivacyPreferences() async {
    try {
      final response = await _apiClient.get('/api/v1/me/privacy');
      return response.data!['leaderboard_visible'] as bool;
    } on ApiClientException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<bool> updatePrivacyPreferences({
    required bool leaderboardVisible,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/api/v1/me/privacy',
        body: <String, Object?>{'leaderboard_visible': leaderboardVisible},
      );
      return response.data!['leaderboard_visible'] as bool;
    } on ApiClientException catch (e) {
      throw _mapException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  static UserProfileError _mapException(ApiClientException e) {
    switch (e) {
      case ApiClientAuthorizationException(:final statusCode):
        return statusCode == 403
            ? const UserProfileForbiddenError()
            : const UserProfileUnauthorizedError();
      case ApiClientNetworkException():
        return const UserProfileNetworkError();
      case ApiClientClientException(:final statusCode, :final data):
        if (statusCode == 409) return const UserProfileUsernameTakenError();
        final serverCode = _serverErrorCode(data);
        if (serverCode == 'VALIDATION_ERROR') {
          return const UserProfileValidationError();
        }
        return UserProfileUnknownError(e);
    }
  }

  static String? _serverErrorCode(Object? data) {
    if (data is! Map<String, Object?>) return null;
    final error = data['error'];
    if (error is! Map<String, Object?>) return null;
    return error['code'] as String?;
  }
}
