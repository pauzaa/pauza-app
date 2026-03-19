import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:pauza/src/core/localization/l10n.dart';

part 'api_error.dart';
part 'api_model.dart';

/// {@template api_client}
/// An HTTP client that sends requests to a REST API.
/// {@endtemplate}
class ApiClient {
  ApiClient({required String baseUrl, Client? client, Iterable<ApiClientMiddleware>? middlewares})
    : _baseUrl = Uri.parse(baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl),
      assert(!baseUrl.endsWith('//'), 'Invalid base URL.') {
    // Create the HTTP client.
    final internalClient = client ?? Client();

    // Combine all middlewares into a single middleware function.
    final effectiveMiddlewares = [
      /* default middlewares before custom middlewares */
      ...?middlewares,
      /* default middlewares after custom middlewares */
    ];
    ApiClientHandler mw(ApiClientHandler handler) => effectiveMiddlewares.reversed.fold(handler, (h, m) => m.call(h));

    // Create the handler.
    _handler = _createHandler(internalClient, mw);
  }

  final Uri _baseUrl;
  late final ApiClientHandler _handler;

  /// Merges the given [path] with the base URL.
  static Uri _mergePath(Uri base, String path, Map<String, Object>? queryParameters) {
    if (path.startsWith('http')) return Uri.parse(path);
    var method = path;
    while (method.startsWith('/')) {
      method = method.substring(1);
    }

    // Convert all query parameter values to strings
    final stringQueryParameters = queryParameters?.map((key, value) => MapEntry(key, value.toString()));

    return base.replace(path: '${base.path}/$method', queryParameters: stringQueryParameters);
  }

  /// Creates the correct http request based on the body type.
  static BaseRequest _createRequest(String method, Uri url, Map<String, String>? headers, Object? body) {
    BaseRequest request;
    if (body is Stream<List<int>>) {
      final streamedRequest = StreamedRequest(method, url);
      body.listen(streamedRequest.sink.add, onDone: streamedRequest.sink.close, onError: streamedRequest.sink.addError);
      request = streamedRequest;
    } else if (body is MultipartFile) {
      final multipartRequest = MultipartRequest(method, url);
      multipartRequest.files.add(body);
      request = multipartRequest;
    } else {
      final regularRequest = Request(method, url);
      if (body is Map) {
        final bytes = const JsonEncoder().fuse(const Utf8Encoder()).convert(body as Map<String, Object?>);
        regularRequest.headers
          ..['Content-Type'] = 'application/json; charset=UTF-8'
          ..['Content-Length'] = bytes.length.toString();
        regularRequest.bodyBytes = bytes;
      }
      request = regularRequest;
    }

    request.headers['Accept'] = 'application/json';
    if (headers != null) request.headers.addAll(headers);
    return request;
  }

  Future<ApiClientResponse> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? queryParameters,
    Map<String, Object?>? context,
  }) async {
    final url = _mergePath(_baseUrl, path, queryParameters);
    final request = _createRequest(method, url, headers, body);
    final effectiveContext = context ?? <String, Object?>{};
    return _handler(ApiClientRequest(request), effectiveContext);
  }

  Future<ApiClientResponse> get(
    String path, {
    Map<String, String>? headers,
    Map<String, Object>? queryParameters,
    Map<String, Object?>? context,
  }) => _send('GET', path, headers: headers, queryParameters: queryParameters, context: context);

  Future<ApiClientResponse> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? queryParameters,
    Map<String, Object?>? context,
  }) => _send('POST', path, body: body, headers: headers, queryParameters: queryParameters, context: context);

  Future<ApiClientResponse> postFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    MediaType? contentType,
    Map<String, String>? headers,
    Map<String, Object>? queryParameters,
    Map<String, Object?>? context,
  }) async {
    final file = await MultipartFile.fromPath(fieldName, filePath, contentType: contentType);
    return _send('POST', path, body: file, headers: headers, queryParameters: queryParameters, context: context);
  }

  Future<ApiClientResponse> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? queryParameters,
    Map<String, Object?>? context,
  }) => _send('PUT', path, body: body, headers: headers, queryParameters: queryParameters, context: context);

  Future<ApiClientResponse> patch(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? queryParameters,
    Map<String, Object?>? context,
  }) => _send('PATCH', path, body: body, headers: headers, queryParameters: queryParameters, context: context);

  Future<ApiClientResponse> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, Object>? queryParameters,
    Map<String, Object?>? context,
  }) => _send('DELETE', path, headers: headers, queryParameters: queryParameters, context: context);
}

// Exceptions
@immutable
sealed class ApiClientException implements Exception {
  const ApiClientException({
    required this.code,
    required this.message,
    required this.statusCode,
    this.error,
    this.data,
    this.responseHeaders = const <String, String>{},
  });

  /// HTTP status code. Will be 0 if the request was not sent.
  final int statusCode;
  final String code;
  final String message;
  final Object? error;
  final Object? data;

  /// Response headers from the server (empty when no response was received).
  final Map<String, String> responseHeaders;

  @override
  String toString() => 'ApiClientException($code): $message';
}

/// Represents a client-side error (e.g., 4xx status codes).
final class ApiClientClientException extends ApiClientException {
  const ApiClientClientException({
    required super.code,
    required super.message,
    required super.statusCode,
    super.error,
    super.data,
    super.responseHeaders,
  });
}

/// Represents a network or server-side error (e.g., 5xx status codes, connectivity issues).
final class ApiClientNetworkException extends ApiClientException {
  const ApiClientNetworkException({
    required super.code,
    required super.message,
    required super.statusCode,
    super.error,
    super.data,
    super.responseHeaders,
  });
}

/// Represents an authorization error (e.g., 401 Unauthorized).
final class ApiClientAuthorizationException extends ApiClientException {
  const ApiClientAuthorizationException({
    required super.code,
    required super.message,
    required super.statusCode,
    super.error,
    super.data,
    super.responseHeaders,
  });
}
