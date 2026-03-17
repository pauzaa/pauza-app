import 'dart:async';
import 'dart:developer' as developer;

import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/api_client/cache/cache_policy.dart';
import 'package:pauza/src/core/api_client/cache/cached_api_response.dart';
import 'package:pauza/src/core/api_client/cache/http_cache_store.dart';

class ApiClientCacheMiddleware implements ApiClientMiddleware {
  const ApiClientCacheMiddleware({
    required HttpCacheStore cacheStore,
    required List<CachePolicy> policies,
    DateTime Function()? nowUtc,
  }) : _cacheStore = cacheStore,
       _policies = policies,
       _nowUtc = nowUtc;

  final HttpCacheStore _cacheStore;
  final List<CachePolicy> _policies;
  final DateTime Function()? _nowUtc;

  static const skipCacheKey = 'skipCache';
  static const invalidatePrefixKey = 'invalidateCachePrefix';

  DateTime _now() => _nowUtc?.call() ?? DateTime.now().toUtc();

  @override
  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    // Handle cache invalidation on any request type.
    final invalidatePrefix = context[invalidatePrefixKey];
    if (invalidatePrefix is String && invalidatePrefix.isNotEmpty) {
      await _cacheStore.deleteByPrefix(invalidatePrefix);
    }

    // Only cache GET requests.
    if (request.method != 'GET') {
      return innerHandler(request, context);
    }

    final policy = _findPolicy(request.url.path);
    if (policy == null) {
      return innerHandler(request, context);
    }

    final skipCache = context[skipCacheKey] == true;
    final cacheKey = _buildCacheKey(request);

    if (!skipCache) {
      final cached = await _cacheStore.get(cacheKey);
      if (cached != null) {
        final nowUtc = _now();
        if (cached.isFresh(nowUtc, policy.ttl)) {
          return _toResponse(cached, request);
        }

        // Stale: return cached immediately, refresh in background.
        unawaited(_backgroundRefresh(innerHandler, request, Map<String, Object?>.of(context), cacheKey));
        return _toResponse(cached, request);
      }
    }

    // Cache miss or skipCache: go to network.
    final response = await innerHandler(request, context);
    await _cacheResponse(cacheKey, response);
    return response;
  };

  String _buildCacheKey(ApiClientRequest request) {
    final uri = request.url;
    final sortedParams = uri.queryParameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final queryString = sortedParams.map((e) => '${e.key}=${e.value}').join('&');
    if (queryString.isEmpty) return 'GET:${uri.path}';
    return 'GET:${uri.path}?$queryString';
  }

  CachePolicy? _findPolicy(String path) {
    for (final policy in _policies) {
      if (policy.pattern.hasMatch(path)) return policy;
    }
    return null;
  }

  Future<void> _backgroundRefresh(
    ApiClientHandler innerHandler,
    ApiClientRequest request,
    Map<String, Object?> context,
    String cacheKey,
  ) async {
    try {
      final response = await innerHandler(request, context);
      await _cacheResponse(cacheKey, response);
    } on Object catch (e) {
      developer.log('Cache background refresh failed: $e', name: 'http_cache');
    }
  }

  Future<void> _cacheResponse(String cacheKey, ApiClientResponse response) async {
    if (response.statusCode < 200 || response.statusCode > 299) return;
    final entry = CachedApiResponse(
      statusCode: response.statusCode,
      headers: response.headers,
      contentLength: response.contentLength,
      data: response.data,
      cachedAtUtcMs: _now().millisecondsSinceEpoch,
      url: response.request.url.toString(),
    );
    await _cacheStore.put(cacheKey, entry);
  }

  ApiClientResponse _toResponse(CachedApiResponse cached, ApiClientRequest request) {
    return ApiClientResponse.json(
      cached.data,
      statusCode: cached.statusCode,
      headers: cached.headers,
      contentLength: cached.contentLength,
      persistentConnection: false,
      request: request,
    );
  }
}
