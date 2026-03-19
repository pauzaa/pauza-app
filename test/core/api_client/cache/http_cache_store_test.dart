import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pauza/src/core/api_client/cache/cached_api_response.dart';
import 'package:pauza/src/core/api_client/cache/http_cache_store.dart';

void main() {
  late Directory tempDir;
  late Box<String> box;
  late HiveHttpCacheStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>('test_cache');
    store = HiveHttpCacheStore(box: box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  CachedApiResponse makeEntry({String url = 'https://api.pauza.dev/api/v1/me', int statusCode = 200}) {
    return CachedApiResponse(
      statusCode: statusCode,
      headers: const {'content-type': 'application/json'},
      contentLength: 2,
      data: const <String, Object?>{},
      cachedAtUtcMs: DateTime.utc(2024).millisecondsSinceEpoch,
      url: url,
    );
  }

  group('HiveHttpCacheStore', () {
    test('get returns null for missing key', () async {
      final result = await store.get('GET:/api/v1/me');
      expect(result, isNull);
    });

    test('get returns stored entry after put', () async {
      final entry = makeEntry();
      await store.put('GET:/api/v1/me', entry);

      final result = await store.get('GET:/api/v1/me');
      expect(result, isNotNull);
      expect(result!.statusCode, 200);
      expect(result.url, 'https://api.pauza.dev/api/v1/me');
    });

    test('put overwrites existing entry', () async {
      await store.put('GET:/api/v1/me', makeEntry());
      await store.put('GET:/api/v1/me', makeEntry(statusCode: 201));

      final result = await store.get('GET:/api/v1/me');
      expect(result!.statusCode, 201);
    });

    test('deleteByPrefix deletes matching simple keys', () async {
      await store.put('GET:/me', makeEntry());
      await store.put('GET:/friends', makeEntry());

      await store.deleteByPrefix('/me');

      expect(await store.get('GET:/me'), isNull);
      expect(await store.get('GET:/friends'), isNotNull);
    });

    test('deleteByPrefix deletes matching full-path keys (regression)', () async {
      await store.put('GET:/api/v1/me', makeEntry());
      await store.put('GET:/api/v1/friends', makeEntry());

      await store.deleteByPrefix('/me');

      expect(await store.get('GET:/api/v1/me'), isNull);
      expect(await store.get('GET:/api/v1/friends'), isNotNull);
    });

    test('deleteByPrefix does not delete non-matching keys', () async {
      await store.put('GET:/api/v1/friends', makeEntry());

      await store.deleteByPrefix('/me');

      expect(await store.get('GET:/api/v1/friends'), isNotNull);
    });

    test('deleteByPrefix with no matching keys is a no-op', () async {
      await store.put('GET:/api/v1/friends', makeEntry());

      await store.deleteByPrefix('/nonexistent');

      expect(await store.get('GET:/api/v1/friends'), isNotNull);
    });

    test('clear removes all entries', () async {
      await store.put('GET:/api/v1/me', makeEntry());
      await store.put('GET:/api/v1/friends', makeEntry());

      await store.clear();

      expect(await store.get('GET:/api/v1/me'), isNull);
      expect(await store.get('GET:/api/v1/friends'), isNull);
    });
  });
}
