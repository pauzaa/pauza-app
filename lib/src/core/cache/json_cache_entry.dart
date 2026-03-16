import 'package:flutter/foundation.dart';

@immutable
final class JsonCacheEntry<T> {
  const JsonCacheEntry({required this.data, required this.cachedAtUtc});

  final T data;
  final DateTime cachedAtUtc;

  bool isFresh({required DateTime nowUtc, required Duration ttl}) {
    if (cachedAtUtc.isAfter(nowUtc)) {
      return false;
    }
    return nowUtc.difference(cachedAtUtc) <= ttl;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JsonCacheEntry<T> && other.data == data && other.cachedAtUtc == cachedAtUtc;
  }

  @override
  int get hashCode => Object.hash(data, cachedAtUtc);

  @override
  String toString() => 'JsonCacheEntry<$T>(data: $data, cachedAtUtc: $cachedAtUtc)';
}
