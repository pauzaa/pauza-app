import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/api_client/cache/cache_mw.dart';
import 'package:pauza/src/core/api_client/cache/cache_policy.dart';
import 'package:pauza/src/core/api_client/cache/cached_api_response.dart';
import 'package:pauza/src/core/api_client/cache/http_cache_store.dart';

/// In-memory implementation of [HttpCacheStore] for testing.
final class FakeHttpCacheStore implements HttpCacheStore {
  final Map<String, CachedApiResponse> _store = {};

  @override
  Future<CachedApiResponse?> get(String key) async => _store[key];

  @override
  Future<void> put(String key, CachedApiResponse entry) async => _store[key] = entry;

  @override
  Future<void> deleteByPrefix(String prefix) async {
    _store.removeWhere((key, _) => key.contains(prefix));
  }

  @override
  Future<void> clear() async => _store.clear();

  bool containsKey(String key) => _store.containsKey(key);
}

ApiClientRequest _getRequest(String path) {
  return ApiClientRequest(Request('GET', Uri.parse('https://api.pauza.dev$path')));
}

ApiClientRequest _patchRequest(String path) {
  return ApiClientRequest(Request('PATCH', Uri.parse('https://api.pauza.dev$path')));
}

ApiClientRequest _postRequest(String path) {
  return ApiClientRequest(Request('POST', Uri.parse('https://api.pauza.dev$path')));
}

ApiClientRequest _deleteRequest(String path) {
  return ApiClientRequest(Request('DELETE', Uri.parse('https://api.pauza.dev$path')));
}

ApiClientResponse _okResponse(ApiClientRequest request, {Map<String, Object?>? data}) {
  return ApiClientResponse.json(
    data ?? const {'ok': true},
    statusCode: 200,
    headers: const {'content-type': 'application/json'},
    contentLength: 0,
    persistentConnection: false,
    request: request,
  );
}

void main() {
  late FakeHttpCacheStore cacheStore;
  late int networkCallCount;
  late DateTime fakeNow;

  final policies = [
    CachePolicy(pattern: RegExp(r'/me'), ttl: const Duration(minutes: 5)),
    CachePolicy(pattern: RegExp(r'/friends'), ttl: const Duration(minutes: 5)),
  ];

  ApiClientHandler fakeInner() => (request, context) async {
    networkCallCount++;
    return _okResponse(request);
  };

  ApiClientCacheMiddleware createMiddleware() {
    return ApiClientCacheMiddleware(cacheStore: cacheStore, policies: policies, nowUtc: () => fakeNow);
  }

  setUp(() {
    cacheStore = FakeHttpCacheStore();
    networkCallCount = 0;
    fakeNow = DateTime.utc(2024, 1, 1, 12, 0);
  });

  group('ApiClientCacheMiddleware', () {
    test('GET request: first call goes to network and caches response', () async {
      final mw = createMiddleware();
      final handler = mw.call(fakeInner());

      await handler(_getRequest('/api/v1/me'), {});

      expect(networkCallCount, 1);
      expect(cacheStore.containsKey('GET:/api/v1/me'), isTrue);
    });

    test('GET request: second call within TTL returns cached response without network', () async {
      final mw = createMiddleware();
      final handler = mw.call(fakeInner());
      final request = _getRequest('/api/v1/me');

      await handler(request, {});
      expect(networkCallCount, 1);

      // Second call — should be cached.
      final request2 = _getRequest('/api/v1/me');
      await handler(request2, {});
      expect(networkCallCount, 1);
    });

    test('GET request with skipCache bypasses cache and goes to network', () async {
      final mw = createMiddleware();
      final handler = mw.call(fakeInner());

      // Prime cache.
      await handler(_getRequest('/api/v1/me'), {});
      expect(networkCallCount, 1);

      // Skip cache.
      await handler(_getRequest('/api/v1/me'), {ApiClientCacheMiddleware.skipCacheKey: true});
      expect(networkCallCount, 2);
    });

    test('stale cache returns cached immediately and triggers background refresh', () async {
      final mw = createMiddleware();
      final handler = mw.call(fakeInner());

      // Prime cache.
      await handler(_getRequest('/api/v1/me'), {});
      expect(networkCallCount, 1);

      // Advance past TTL.
      fakeNow = fakeNow.add(const Duration(minutes: 10));

      final response = await handler(_getRequest('/api/v1/me'), {});
      expect(response.statusCode, 200);

      // Background refresh is unawaited — give it a tick to execute.
      await Future<void>.delayed(Duration.zero);
      expect(networkCallCount, 2);
    });

    test('invalidatePrefixKey clears matching cache entries before delegating', () async {
      final mw = createMiddleware();
      final handler = mw.call(fakeInner());

      // Prime cache.
      await handler(_getRequest('/api/v1/me'), {});
      expect(cacheStore.containsKey('GET:/api/v1/me'), isTrue);

      // Invalidate via a PATCH.
      await handler(_patchRequest('/api/v1/me'), {ApiClientCacheMiddleware.invalidatePrefixKey: '/me'});

      expect(cacheStore.containsKey('GET:/api/v1/me'), isFalse);
    });

    test('PATCH requests are never cached', () async {
      final mw = createMiddleware();
      final handler = mw.call(fakeInner());

      await handler(_patchRequest('/api/v1/me'), {});
      expect(cacheStore.containsKey('PATCH:/api/v1/me'), isFalse);
      expect(networkCallCount, 1);
    });

    test('POST requests are never cached', () async {
      final mw = createMiddleware();
      final handler = mw.call(fakeInner());

      await handler(_postRequest('/api/v1/me'), {});
      expect(cacheStore.containsKey('POST:/api/v1/me'), isFalse);
      expect(networkCallCount, 1);
    });

    test('DELETE requests are never cached', () async {
      final mw = createMiddleware();
      final handler = mw.call(fakeInner());

      await handler(_deleteRequest('/api/v1/me'), {});
      expect(cacheStore.containsKey('DELETE:/api/v1/me'), isFalse);
      expect(networkCallCount, 1);
    });

    test('GET request with no matching policy is not cached', () async {
      final mw = createMiddleware();
      final handler = mw.call(fakeInner());

      await handler(_getRequest('/api/v1/other'), {});
      expect(networkCallCount, 1);
      expect(cacheStore.containsKey('GET:/api/v1/other'), isFalse);
    });

    test('cache invalidation + subsequent GET goes to network (end-to-end)', () async {
      final mw = createMiddleware();
      final handler = mw.call(fakeInner());

      // 1. Prime cache with GET /me.
      await handler(_getRequest('/api/v1/me'), {});
      expect(networkCallCount, 1);

      // 2. PATCH /me invalidates /me cache.
      await handler(_patchRequest('/api/v1/me'), {ApiClientCacheMiddleware.invalidatePrefixKey: '/me'});
      expect(networkCallCount, 2);

      // 3. GET /me should go to network (cache was invalidated).
      await handler(_getRequest('/api/v1/me'), {});
      expect(networkCallCount, 3);
    });
  });
}
