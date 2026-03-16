final class CacheStorageError implements Exception {
  const CacheStorageError([this.cause]);

  final Object? cause;

  @override
  String toString() => 'CacheStorageError(cause: $cause)';
}
