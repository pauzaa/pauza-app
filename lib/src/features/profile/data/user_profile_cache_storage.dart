import 'package:appfuse/appfuse.dart';
import 'package:pauza/src/core/cache/json_cache_entry.dart';
import 'package:pauza/src/core/cache/json_cache_storage.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';

abstract interface class UserProfileCacheStorage {
  Future<JsonCacheEntry<UserDto>?> read();

  Future<void> write(UserDto user);

  Future<void> delete();
}

final class AppFuseUserProfileCacheStorage implements UserProfileCacheStorage {
  AppFuseUserProfileCacheStorage({required IAppFuseStorage storage, required DateTime Function() nowUtc})
    : _delegate = AppFuseJsonCacheStorage<UserDto>(
        storage: storage,
        cacheKey: 'auth.user_profile.cache.v1',
        fromJson: UserDto.fromJson,
        toJson: (user) => user.toJson(),
        nowUtc: nowUtc,
      );

  final AppFuseJsonCacheStorage<UserDto> _delegate;

  @override
  Future<JsonCacheEntry<UserDto>?> read() => _delegate.read();

  @override
  Future<void> write(UserDto user) => _delegate.write(user);

  @override
  Future<void> delete() => _delegate.delete();
}
