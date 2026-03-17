import 'package:meta/meta.dart';

@immutable
final class CachePolicy {
  const CachePolicy({required this.pattern, required this.ttl});

  final RegExp pattern;
  final Duration ttl;

  @override
  String toString() => 'CachePolicy(pattern: ${pattern.pattern}, ttl: $ttl)';
}
