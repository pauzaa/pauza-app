import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/data/user_profile_cache_storage.dart';
import 'package:pauza/src/features/profile/data/user_profile_remote_data_source.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';

void main() {
  group('UserProfileRepositoryImpl', () {
    test('fetchAndCacheProfile writes cache and returns user', () async {
      final cache = _FakeUserProfileCacheStorage();
      final remote = _FakeUserProfileRemoteDataSource(
        user: const UserDto(
          profilePicture: 'https://example.com/avatar/john.png',
          username: 'john',
          name: 'John',
        ),
      );
      final repository = UserProfileRepositoryImpl(
        cacheStorage: cache,
        remoteDataSource: remote,
        nowUtc: () => DateTime.utc(2026, 2, 16, 10),
      );

      final user = await repository.fetchAndCacheProfile(
        session: const Session(accessToken: 'access', refreshToken: 'refresh'),
      );

      expect(user.username, 'john');
      expect(cache.cached?.user, user);
      expect(cache.cached?.cachedAtUtc, DateTime.utc(2026, 2, 16, 10));
    });

    test('readCachedProfile delegates to cache storage', () async {
      final cache = _FakeUserProfileCacheStorage(
        cached: CachedUserProfile(
          user: const UserDto(
            profilePicture: 'https://example.com/avatar/jane.png',
            username: 'jane',
            name: 'Jane',
          ),
          cachedAtUtc: DateTime.utc(2026, 2, 16, 11),
        ),
      );
      final remote = _FakeUserProfileRemoteDataSource(
        user: const UserDto(
          profilePicture: 'https://example.com/avatar/jane.png',
          username: 'jane',
          name: 'Jane',
        ),
      );
      final repository = UserProfileRepositoryImpl(
        cacheStorage: cache,
        remoteDataSource: remote,
        nowUtc: DateTime.now,
      );

      final cached = await repository.readCachedProfile();

      expect(cached, cache.cached);
    });

    test('fetchAndCacheProfile propagates typed remote errors', () async {
      final cache = _FakeUserProfileCacheStorage();
      final remote = _FakeUserProfileRemoteDataSource(
        error: const UserProfileException(code: UserProfileFailureCode.network),
      );
      final repository = UserProfileRepositoryImpl(
        cacheStorage: cache,
        remoteDataSource: remote,
        nowUtc: DateTime.now,
      );

      await expectLater(
        () => repository.fetchAndCacheProfile(
          session: const Session(accessToken: 'a', refreshToken: 'b'),
        ),
        throwsA(
          isA<UserProfileException>().having(
            (error) => error.code,
            'code',
            UserProfileFailureCode.network,
          ),
        ),
      );
      expect(cache.cached, isNull);
    });
  });
}

final class _FakeUserProfileCacheStorage implements UserProfileCacheStorage {
  _FakeUserProfileCacheStorage({this.cached});

  CachedUserProfile? cached;

  @override
  Future<void> delete() async {
    cached = null;
  }

  @override
  Future<CachedUserProfile?> read() async {
    return cached;
  }

  @override
  Future<void> write(CachedUserProfile cached) async {
    this.cached = cached;
  }
}

final class _FakeUserProfileRemoteDataSource
    implements UserProfileRemoteDataSource {
  _FakeUserProfileRemoteDataSource({this.user, this.error});

  final UserDto? user;
  final UserProfileException? error;

  @override
  Future<UserDto> fetchMe({required Session session}) async {
    if (error case final remoteError?) {
      throw remoteError;
    }
    return user!;
  }
}
