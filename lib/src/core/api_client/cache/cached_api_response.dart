import 'package:meta/meta.dart';

@immutable
final class CachedApiResponse {
  const CachedApiResponse({
    required this.statusCode,
    required this.headers,
    required this.contentLength,
    required this.data,
    required this.cachedAtUtcMs,
    required this.url,
  });

  factory CachedApiResponse.fromJson(Map<String, Object?> json) {
    return CachedApiResponse(
      statusCode: json['statusCode'] as int,
      headers: (json['headers'] as Map<String, Object?>).cast<String, String>(),
      contentLength: json['contentLength'] as int,
      data: json['data'] as Map<String, Object?>?,
      cachedAtUtcMs: json['cachedAtUtcMs'] as int,
      url: json['url'] as String,
    );
  }

  final int statusCode;
  final Map<String, String> headers;
  final int contentLength;
  final Map<String, Object?>? data;
  final int cachedAtUtcMs;
  final String url;

  bool isFresh(DateTime nowUtc, Duration ttl) {
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtUtcMs, isUtc: true);
    if (cachedAt.isAfter(nowUtc)) return false;
    return nowUtc.difference(cachedAt) <= ttl;
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'statusCode': statusCode,
      'headers': headers,
      'contentLength': contentLength,
      'data': data,
      'cachedAtUtcMs': cachedAtUtcMs,
      'url': url,
    };
  }

  @override
  String toString() => 'CachedApiResponse(url: $url, statusCode: $statusCode, cachedAtUtcMs: $cachedAtUtcMs)';
}
