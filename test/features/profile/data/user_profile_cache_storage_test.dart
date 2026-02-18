import 'package:appfuse/appfuse.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/data/user_profile_cache_storage.dart';

void main() {
  group('AppFuseUserProfileCacheStorage', () {
    test('read returns null when cache is absent', () async {
      final storage = AppFuseUserProfileCacheStorage(storage: _FakeAppFuseStorage());

      final cached = await storage.read();

      expect(cached, isNull);
    });

    test('write and read roundtrip cached user profile', () async {
      final kv = _FakeAppFuseStorage();
      final storage = AppFuseUserProfileCacheStorage(storage: kv);
      final now = DateTime.utc(2026, 2, 16, 8);
      final cached = CachedUserProfile(
        user: const UserDto(profilePicture: 'https://example.com/avatar/john.png', username: 'john', name: 'John'),
        cachedAtUtc: now,
      );

      await storage.write(cached);
      final restored = await storage.read();

      expect(restored, cached);
    });

    test('delete clears existing cache payload', () async {
      final kv = _FakeAppFuseStorage();
      final storage = AppFuseUserProfileCacheStorage(storage: kv);
      final cached = CachedUserProfile(
        user: const UserDto(profilePicture: 'https://example.com/avatar/jane.png', username: 'jane', name: 'Jane'),
        cachedAtUtc: DateTime.utc(2026, 2, 16, 9),
      );

      await storage.write(cached);
      await storage.delete();
      final restored = await storage.read();

      expect(restored, isNull);
    });

    test('read throws storage failure for malformed payload', () async {
      final kv = _FakeAppFuseStorage(values: <String, Object?>{AppFuseUserProfileCacheStorage.cacheKey: 'not-json'});
      final storage = AppFuseUserProfileCacheStorage(storage: kv);

      await expectLater(
        storage.read,
        throwsA(isA<UserProfileException>().having((error) => error.code, 'code', UserProfileFailureCode.storage)),
      );
    });

    test('write throws storage failure when setValue returns false', () async {
      final kv = _FakeAppFuseStorage(setValueResult: false);
      final storage = AppFuseUserProfileCacheStorage(storage: kv);

      await expectLater(
        () => storage.write(
          CachedUserProfile(
            user: const UserDto(profilePicture: 'https://example.com/avatar/jane.png', username: 'jane', name: 'Jane'),
            cachedAtUtc: DateTime.utc(2026, 2, 16, 9),
          ),
        ),
        throwsA(isA<UserProfileException>().having((error) => error.code, 'code', UserProfileFailureCode.storage)),
      );
    });
  });
}

final class _FakeAppFuseStorage implements IAppFuseStorage {
  _FakeAppFuseStorage({Map<String, Object?>? values, this.setValueResult = true}) : _values = values ?? <String, Object?>{};

  final Map<String, Object?> _values;
  final bool setValueResult;

  @override
  Future<T?> getValue<T>(String key) async {
    final value = _values[key];
    if (value == null) {
      return null;
    }
    return value as T;
  }

  @override
  Future<bool> setValue<T>(String key, T value) async {
    if (!setValueResult) {
      return false;
    }
    _values[key] = value;
    return true;
  }
}
