import 'dart:async';
import 'dart:typed_data';

import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/data/user_profile_cache_storage.dart';
import 'package:pauza/src/features/profile/data/user_profile_remote_data_source.dart';

abstract interface class UserProfileRepository {
  Future<CachedUserProfile?> readCachedProfile();

  Future<UserDto> fetchAndCacheProfile();

  Future<UserDto> updateProfile({
    required String name,
    required String username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  });

  Future<bool> isUsernameAvailable({required String username});

  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String filename,
  });

  Future<bool> fetchNotificationPreferences();

  Future<bool> updateNotificationPreferences({required bool pushEnabled});

  Future<bool> fetchPrivacyPreferences();

  Future<bool> updatePrivacyPreferences({required bool leaderboardVisible});

  Stream<UserDto> watchProfileChanges();

  Future<void> clearCache();
}

final class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl({
    required UserProfileCacheStorage cacheStorage,
    required UserProfileRemoteDataSource remoteDataSource,
    required DateTime Function() nowUtc,
  }) : _cacheStorage = cacheStorage,
       _remoteDataSource = remoteDataSource,
       _nowUtc = nowUtc;

  final UserProfileCacheStorage _cacheStorage;
  final UserProfileRemoteDataSource _remoteDataSource;
  final DateTime Function() _nowUtc;
  final StreamController<UserDto> _profileChangesController =
      StreamController<UserDto>.broadcast();

  @override
  Future<CachedUserProfile?> readCachedProfile() {
    return _cacheStorage.read();
  }

  @override
  Future<UserDto> fetchAndCacheProfile() async {
    try {
      final user = await _remoteDataSource.fetchMe();
      await _writeCacheAndNotify(user);
      return user;
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<UserDto> updateProfile({
    required String name,
    required String username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  }) async {
    try {
      if (profilePictureBytes != null) {
        await _remoteDataSource.uploadProfilePhoto(
          bytes: profilePictureBytes,
          filename: 'profile.jpg',
        );
      }

      final updated = await _remoteDataSource.updateMe(
        name: name,
        username: username,
      );
      await _writeCacheAndNotify(updated);
      return updated;
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<bool> isUsernameAvailable({required String username}) async {
    try {
      return _remoteDataSource.isUsernameAvailable(username: username);
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      return _remoteDataSource.uploadProfilePhoto(
        bytes: bytes,
        filename: filename,
      );
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<bool> fetchNotificationPreferences() async {
    try {
      return _remoteDataSource.fetchNotificationPreferences();
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<bool> updateNotificationPreferences({
    required bool pushEnabled,
  }) async {
    try {
      final result = await _remoteDataSource.updateNotificationPreferences(
        pushEnabled: pushEnabled,
      );
      await _patchCachedPreference(pushEnabled: result);
      return result;
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<bool> fetchPrivacyPreferences() async {
    try {
      return _remoteDataSource.fetchPrivacyPreferences();
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<bool> updatePrivacyPreferences({
    required bool leaderboardVisible,
  }) async {
    try {
      final result = await _remoteDataSource.updatePrivacyPreferences(
        leaderboardVisible: leaderboardVisible,
      );
      await _patchCachedPreference(leaderboardVisible: result);
      return result;
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Stream<UserDto> watchProfileChanges() {
    return _profileChangesController.stream;
  }

  @override
  Future<void> clearCache() async {
    await _cacheStorage.delete();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _writeCacheAndNotify(UserDto user) async {
    await _cacheStorage.write(
      CachedUserProfile(user: user, cachedAtUtc: _nowUtc()),
    );
    if (!_profileChangesController.isClosed) {
      _profileChangesController.add(user);
    }
  }

  /// Reads the cached profile, patches a single preference field, and
  /// re-writes + notifies so [CurrentUserBloc] stays in sync.
  Future<void> _patchCachedPreference({
    bool? pushEnabled,
    bool? leaderboardVisible,
  }) async {
    final cached = await _cacheStorage.read();
    if (cached == null) return;
    final patched = cached.user.copyWith(
      pushEnabled: pushEnabled,
      leaderboardVisible: leaderboardVisible,
    );
    await _writeCacheAndNotify(patched);
  }
}
