import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:pauza/src/core/api_client/cache/cached_api_response.dart';

abstract interface class HttpCacheStore {
  Future<CachedApiResponse?> get(String key);

  Future<void> put(String key, CachedApiResponse entry);

  Future<void> deleteByPrefix(String prefix);

  Future<void> clear();
}

final class HiveHttpCacheStore implements HttpCacheStore {
  const HiveHttpCacheStore({required Box<String> box}) : _box = box;

  final Box<String> _box;

  @override
  Future<CachedApiResponse?> get(String key) async {
    final raw = _box.get(key);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, Object?>;
    return CachedApiResponse.fromJson(json);
  }

  @override
  Future<void> put(String key, CachedApiResponse entry) async {
    final raw = jsonEncode(entry.toJson());
    await _box.put(key, raw);
  }

  @override
  Future<void> deleteByPrefix(String prefix) async {
    final keysToDelete = _box.keys.whereType<String>().where((key) => key.startsWith('GET:$prefix')).toList();
    if (keysToDelete.isNotEmpty) {
      await _box.deleteAll(keysToDelete);
    }
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
