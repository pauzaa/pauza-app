import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/data/user_profile_cache_storage.dart';
import 'package:pauza/src/features/profile/data/user_profile_remote_data_source.dart';

abstract interface class UserProfileRepository {
  Future<CachedUserProfile?> readCachedProfile();

  Future<UserDto> fetchAndCacheProfile({required Session session});

  Future<void> clearCache();
}

final class UserProfileRepositoryImpl implements UserProfileRepository {
  const UserProfileRepositoryImpl({
    required UserProfileCacheStorage cacheStorage,
    required UserProfileRemoteDataSource remoteDataSource,
    required DateTime Function() nowUtc,
  }) : _cacheStorage = cacheStorage,
       _remoteDataSource = remoteDataSource,
       _nowUtc = nowUtc;

  final UserProfileCacheStorage _cacheStorage;
  final UserProfileRemoteDataSource _remoteDataSource;
  final DateTime Function() _nowUtc;

  @override
  Future<CachedUserProfile?> readCachedProfile() {
    return _cacheStorage.read();
  }

  @override
  Future<UserDto> fetchAndCacheProfile({required Session session}) async {
    try {
      final user = await _remoteDataSource.fetchMe(session: session);
      await _cacheStorage.write(
        CachedUserProfile(user: user, cachedAtUtc: _nowUtc()),
      );
      return user;
    } on UserProfileException {
      rethrow;
    } on Object {
      throw const UserProfileException(code: UserProfileFailureCode.unknown);
    }
  }

  @override
  Future<void> clearCache() {
    return _cacheStorage.delete();
  }
}
