import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/api_client/cache/cached_api_response.dart';

void main() {
  group('CachedApiResponse', () {
    test('isFresh returns true within TTL', () {
      final cachedAt = DateTime.utc(2024, 1, 1, 12);
      final entry = CachedApiResponse(
        statusCode: 200,
        headers: const {},
        contentLength: 0,
        data: const {},
        cachedAtUtcMs: cachedAt.millisecondsSinceEpoch,
        url: 'https://example.com',
      );

      final now = cachedAt.add(const Duration(seconds: 30));
      expect(entry.isFresh(now, const Duration(minutes: 1)), isTrue);
    });

    test('isFresh returns false past TTL', () {
      final cachedAt = DateTime.utc(2024, 1, 1, 12);
      final entry = CachedApiResponse(
        statusCode: 200,
        headers: const {},
        contentLength: 0,
        data: const {},
        cachedAtUtcMs: cachedAt.millisecondsSinceEpoch,
        url: 'https://example.com',
      );

      final now = cachedAt.add(const Duration(minutes: 2));
      expect(entry.isFresh(now, const Duration(minutes: 1)), isFalse);
    });

    test('isFresh returns false if cachedAt is in the future', () {
      final cachedAt = DateTime.utc(2024, 1, 1, 12);
      final entry = CachedApiResponse(
        statusCode: 200,
        headers: const {},
        contentLength: 0,
        data: const {},
        cachedAtUtcMs: cachedAt.millisecondsSinceEpoch,
        url: 'https://example.com',
      );

      final now = cachedAt.subtract(const Duration(minutes: 5));
      expect(entry.isFresh(now, const Duration(minutes: 1)), isFalse);
    });

    test('fromJson / toJson round-trip preserves all fields', () {
      const original = CachedApiResponse(
        statusCode: 200,
        headers: {'content-type': 'application/json'},
        contentLength: 42,
        data: {'key': 'value'},
        cachedAtUtcMs: 1704067200000,
        url: 'https://api.pauza.dev/api/v1/me',
      );

      final json = original.toJson();
      final restored = CachedApiResponse.fromJson(json);

      expect(restored.statusCode, original.statusCode);
      expect(restored.headers, original.headers);
      expect(restored.contentLength, original.contentLength);
      expect(restored.data, original.data);
      expect(restored.cachedAtUtcMs, original.cachedAtUtcMs);
      expect(restored.url, original.url);
    });
  });
}
