import 'dart:convert';

import 'package:appfuse/appfuse.dart';
import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';

abstract interface class UserProfileCacheStorage {
  Future<CachedUserProfile?> read();

  Future<void> write(CachedUserProfile cached);

  Future<void> delete();
}

final class AppFuseUserProfileCacheStorage implements UserProfileCacheStorage {
  const AppFuseUserProfileCacheStorage({required IAppFuseStorage storage}) : _storage = storage;

  static const String cacheKey = 'auth.user_profile.cache.v1';

  final IAppFuseStorage _storage;

  @override
  Future<CachedUserProfile?> read() async {
    try {
      final raw = await _storage.getValue<String>(cacheKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        throw const UserProfileException(
          code: UserProfileFailureCode.storage,
          message: 'Invalid cached user payload shape.',
        );
      }

      return CachedUserProfile.fromJson(decoded);
    } on UserProfileException {
      rethrow;
    } on FormatException {
      throw const UserProfileException(code: UserProfileFailureCode.storage, message: 'Invalid cached user payload.');
    } on Object {
      throw const UserProfileException(
        code: UserProfileFailureCode.storage,
        message: 'Failed to read cached user payload.',
      );
    }
  }

  @override
  Future<void> write(CachedUserProfile cached) async {
    try {
      final raw = jsonEncode(cached.toJson());
      final saved = await _storage.setValue<String>(cacheKey, raw);
      if (!saved) {
        throw const UserProfileException(
          code: UserProfileFailureCode.storage,
          message: 'Failed to write cached user payload.',
        );
      }
    } on UserProfileException {
      rethrow;
    } on Object {
      throw const UserProfileException(
        code: UserProfileFailureCode.storage,
        message: 'Failed to write cached user payload.',
      );
    }
  }

  @override
  Future<void> delete() async {
    try {
      final deleted = await _storage.setValue<String>(cacheKey, '');
      if (!deleted) {
        throw const UserProfileException(
          code: UserProfileFailureCode.storage,
          message: 'Failed to delete cached user payload.',
        );
      }
    } on UserProfileException {
      rethrow;
    } on Object {
      throw const UserProfileException(
        code: UserProfileFailureCode.storage,
        message: 'Failed to delete cached user payload.',
      );
    }
  }
}
