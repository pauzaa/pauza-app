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

  Future<String> uploadProfilePhoto({required String localFilePath});

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
  final StreamController<UserDto> _profileChangesController = StreamController<UserDto>.broadcast();

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
    } on UserProfileException {
      rethrow;
    } on Object {
      throw const UserProfileException(code: UserProfileFailureCode.unknown);
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
      final updated = await _remoteDataSource.updateMe(
        name: name,
        username: username,
        profilePictureUrl: profilePictureUrl,
        profilePictureBytes: profilePictureBytes,
      );
      await _writeCacheAndNotify(updated);
      return updated;
    } on UserProfileException {
      rethrow;
    } on Object {
      throw const UserProfileException(code: UserProfileFailureCode.unknown);
    }
  }

  @override
  Future<bool> isUsernameAvailable({required String username}) async {
    try {
      return _remoteDataSource.isUsernameAvailable(username: username);
    } on UserProfileException {
      rethrow;
    } on Object {
      throw const UserProfileException(code: UserProfileFailureCode.unknown);
    }
  }

  @override
  Future<String> uploadProfilePhoto({required String localFilePath}) async {
    try {
      return _remoteDataSource.uploadProfilePhoto(localFilePath: localFilePath);
    } on UserProfileException {
      rethrow;
    } on Object {
      throw const UserProfileException(code: UserProfileFailureCode.unknown);
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

  Future<void> _writeCacheAndNotify(UserDto user) async {
    await _cacheStorage.write(CachedUserProfile(user: user, cachedAtUtc: _nowUtc()));
    if (!_profileChangesController.isClosed) {
      _profileChangesController.add(user);
    }
  }
}
