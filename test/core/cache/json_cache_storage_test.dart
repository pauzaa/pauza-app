import 'package:appfuse/appfuse.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/core/cache/cache_storage_error.dart';
import 'package:pauza/src/core/cache/json_cache_storage.dart';

class _MockAppFuseStorage extends Mock implements IAppFuseStorage {}

void main() {
  late _MockAppFuseStorage storage;
  late DateTime fakeNow;

  AppFuseJsonCacheStorage<Map<String, Object?>> buildStorage() {
    return AppFuseJsonCacheStorage<Map<String, Object?>>(
      storage: storage,
      cacheKey: 'test.cache.v1',
      fromJson: (json) => json,
      toJson: (data) => data,
      nowUtc: () => fakeNow,
    );
  }

  setUp(() {
    storage = _MockAppFuseStorage();
    fakeNow = DateTime.utc(2026, 3, 17);
  });

  group('AppFuseJsonCacheStorage', () {
    test('read returns null when storage is empty', () async {
      when(() => storage.getValue<String>('test.cache.v1')).thenAnswer((_) async => null);

      final cache = buildStorage();
      final result = await cache.read();

      expect(result, isNull);
    });

    test('read returns null when storage contains empty string', () async {
      when(() => storage.getValue<String>('test.cache.v1')).thenAnswer((_) async => '');

      final cache = buildStorage();
      final result = await cache.read();

      expect(result, isNull);
    });

    test('write then read round-trip preserves data and timestamp', () async {
      String? stored;
      when(() => storage.setValue<String>('test.cache.v1', any())).thenAnswer((inv) async {
        stored = inv.positionalArguments[1] as String;
        return true;
      });
      when(() => storage.getValue<String>('test.cache.v1')).thenAnswer((_) async => stored);

      final cache = buildStorage();
      final data = <String, Object?>{'name': 'test', 'value': 42};

      await cache.write(data);
      final entry = await cache.read();

      expect(entry, isNotNull);
      expect(entry!.data, equals(data));
      expect(entry.cachedAtUtc, equals(fakeNow));
    });

    test('delete clears cache so read returns null', () async {
      when(() => storage.setValue<String>('test.cache.v1', '')).thenAnswer((_) async => true);

      final cache = buildStorage();
      await cache.delete();

      verify(() => storage.setValue<String>('test.cache.v1', '')).called(1);
    });

    test('read throws CacheStorageError on malformed JSON', () async {
      when(() => storage.getValue<String>('test.cache.v1')).thenAnswer((_) async => 'not json');

      final cache = buildStorage();

      expect(() => cache.read(), throwsA(isA<CacheStorageError>()));
    });

    test('read throws CacheStorageError when payload has wrong shape', () async {
      when(() => storage.getValue<String>('test.cache.v1')).thenAnswer((_) async => '"just a string"');

      final cache = buildStorage();

      expect(() => cache.read(), throwsA(isA<CacheStorageError>()));
    });

    test('write throws CacheStorageError when storage fails to save', () async {
      when(() => storage.setValue<String>('test.cache.v1', any())).thenAnswer((_) async => false);

      final cache = buildStorage();

      expect(() => cache.write(<String, Object?>{'key': 'value'}), throwsA(isA<CacheStorageError>()));
    });

    test('delete throws CacheStorageError when storage fails to clear', () async {
      when(() => storage.setValue<String>('test.cache.v1', '')).thenAnswer((_) async => false);

      final cache = buildStorage();

      expect(() => cache.delete(), throwsA(isA<CacheStorageError>()));
    });
  });
}
