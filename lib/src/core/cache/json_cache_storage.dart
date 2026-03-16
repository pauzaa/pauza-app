import 'dart:convert';

import 'package:appfuse/appfuse.dart';
import 'package:pauza/src/core/cache/cache_storage_error.dart';
import 'package:pauza/src/core/cache/json_cache_entry.dart';

abstract interface class JsonCacheStorage<T> {
  Future<JsonCacheEntry<T>?> read();

  Future<void> write(T data);

  Future<void> delete();
}

final class AppFuseJsonCacheStorage<T> implements JsonCacheStorage<T> {
  const AppFuseJsonCacheStorage({
    required IAppFuseStorage storage,
    required String cacheKey,
    required T Function(Map<String, Object?> json) fromJson,
    required Map<String, Object?> Function(T data) toJson,
    required DateTime Function() nowUtc,
  }) : _storage = storage,
       _cacheKey = cacheKey,
       _fromJson = fromJson,
       _toJson = toJson,
       _nowUtc = nowUtc;

  final IAppFuseStorage _storage;
  final String _cacheKey;
  final T Function(Map<String, Object?> json) _fromJson;
  final Map<String, Object?> Function(T data) _toJson;
  final DateTime Function() _nowUtc;

  @override
  Future<JsonCacheEntry<T>?> read() async {
    try {
      final raw = await _storage.getValue<String>(_cacheKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        throw const CacheStorageError('Invalid cached payload shape.');
      }

      final dataJson = decoded['data'];
      final cachedAtUtcMs = decoded['cachedAtUtcMs'];
      if (dataJson is! Map<String, Object?> || cachedAtUtcMs is! int) {
        throw const CacheStorageError('Invalid cached payload fields.');
      }

      return JsonCacheEntry<T>(
        data: _fromJson(dataJson),
        cachedAtUtc: DateTime.fromMillisecondsSinceEpoch(cachedAtUtcMs, isUtc: true),
      );
    } on CacheStorageError {
      rethrow;
    } on FormatException catch (e) {
      throw CacheStorageError(e);
    } on Object catch (e) {
      throw CacheStorageError(e);
    }
  }

  @override
  Future<void> write(T data) async {
    try {
      final payload = <String, Object?>{'data': _toJson(data), 'cachedAtUtcMs': _nowUtc().millisecondsSinceEpoch};
      final raw = jsonEncode(payload);
      final saved = await _storage.setValue<String>(_cacheKey, raw);
      if (!saved) {
        throw const CacheStorageError('Failed to write cached payload.');
      }
    } on CacheStorageError {
      rethrow;
    } on Object catch (e) {
      throw CacheStorageError(e);
    }
  }

  @override
  Future<void> delete() async {
    try {
      final deleted = await _storage.setValue<String>(_cacheKey, '');
      if (!deleted) {
        throw const CacheStorageError('Failed to delete cached payload.');
      }
    } on CacheStorageError {
      rethrow;
    } on Object catch (e) {
      throw CacheStorageError(e);
    }
  }
}
