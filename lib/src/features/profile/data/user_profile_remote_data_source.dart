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

  Future<void> requestAccountDeletion();

  Future<void> confirmAccountDeletion({required String otp});
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
      throw UserProfileError.fromApiException(e);
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
      throw UserProfileError.fromApiException(e);
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
      throw UserProfileError.fromApiException(e);
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
      throw UserProfileError.fromApiException(e);
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
      throw UserProfileError.fromApiException(e);
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
      throw UserProfileError.fromApiException(e);
    }
  }

  @override
  Future<bool> fetchPrivacyPreferences() async {
    try {
      final response = await _apiClient.get('/api/v1/me/privacy');
      return response.data!['leaderboard_visible'] as bool;
    } on ApiClientException catch (e) {
      throw UserProfileError.fromApiException(e);
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
      throw UserProfileError.fromApiException(e);
    }
  }

  @override
  Future<void> requestAccountDeletion() async {
    try {
      await _apiClient.post('/api/v1/me/delete/request');
    } on ApiClientException catch (e) {
      throw UserProfileError.fromApiException(e);
    }
  }

  @override
  Future<void> confirmAccountDeletion({required String otp}) async {
    try {
      await _apiClient.post(
        '/api/v1/me/delete/confirm',
        body: <String, Object?>{'otp': otp},
      );
    } on ApiClientException catch (e) {
      throw UserProfileError.fromApiException(e);
    }
  }
}
