import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:pauza/src/core/localization/l10n.dart';

/// An HTTP request with a JSON-encoded body.
extension type ApiClientRequest(BaseRequest _request) implements BaseRequest {}

/// An HTTP response with a fully-buffered, JSON-decoded body.
final class ApiClientResponse {
  /// Create a new HTTP response with a JSON-encoded body.
  ApiClientResponse.json(
    this.data, {
    required this.statusCode,
    required this.headers,
    required this.contentLength,
    required this.persistentConnection,
    required this.request,
  });

  final int statusCode;
  final Map<String, String> headers;
  final int contentLength;
  final Map<String, Object?>? data;
  final bool persistentConnection;
  final ApiClientRequest request;
}

/// A function that takes a [BaseRequest] and returns a [StreamedResponse].
/// The [context] parameter is a map that can be used to store data that should be available to all middleware.
typedef ApiClientHandler = Future<ApiClientResponse> Function(ApiClientRequest request, Map<String, Object?> context);

/// An interface for a middleware that can be used to intercept and modify request and response.
abstract class ApiClientMiddleware {
  /// A function that takes an [ApiClientHandler] and returns a new [ApiClientHandler].
  ApiClientHandler call(ApiClientHandler innerHandler);
}

/// A function that represents a chain of one or more middlewares.
typedef MiddlewareChain = ApiClientHandler Function(ApiClientHandler);

/// Creates a new [ApiClientHandler] from the given [internalClient] and [middleware].
ApiClientHandler _createHandler(Client internalClient, MiddlewareChain middleware) {
  // Check if the completer is completed and throw an error if it is.
  void throwError(Completer<ApiClientResponse> completer, Object error, StackTrace stackTrace) {
    if (completer.isCompleted) {
      return;
    } else if (error is ApiClientException) {
      completer.completeError(error, stackTrace);
    } else {
      completer.completeError(
        ApiClientClientException(code: 'unknown_error', message: 'Unknown error.', statusCode: 0, error: error),
        stackTrace,
      );
    }
  }

  // JSON decoder.
  final jsonDecoder = const Utf8Decoder().fuse(const JsonDecoder());

  // HTTP handler.
  Future<ApiClientResponse> httpHandler(ApiClientRequest request, Map<String, Object?> context) {
    final completer = Completer<ApiClientResponse>();
    // Handle top level errors.
    runZonedGuarded<void>(
      () async {
        assert(request.url.scheme.startsWith('http'), 'Invalid URL: ${request.url}');

        // Send a base request.
        final StreamedResponse streamedResponse;
        try {
          streamedResponse = await internalClient.send(request._request);
        } on Object catch (error, stackTrace) {
          throwError(
            completer,
            ApiClientNetworkException(
              code: 'network_error',
              message: 'Failed to send request due to a network error.',
              statusCode: 0,
              error: error,
            ),
            stackTrace,
          );
          return;
        }

        final statusCode = streamedResponse.statusCode;
        final responseHeaders = streamedResponse.headers;

        // Read the response body before checking status codes so error
        // responses carry the server's JSON envelope.
        Uint8List bytes;
        try {
          bytes = await streamedResponse.stream.toBytes();
        } on Object catch (error, stackTrace) {
          throwError(
            completer,
            ApiClientNetworkException(
              code: 'body_stream_error',
              message: 'Failed to read response stream.',
              statusCode: statusCode,
              error: error,
              responseHeaders: responseHeaders,
            ),
            stackTrace,
          );
          return;
        }

        // Decode the JSON body (for both success and error responses).
        Map<String, Object?>? body;
        try {
          final contentType = responseHeaders['content-type']?.toLowerCase() ?? '';
          if (contentType.contains('application/json') && bytes.isNotEmpty) {
            body = jsonDecoder.convert(bytes) as Map<String, Object?>;
          } else if (bytes.isEmpty) {
            body = <String, Object?>{};
          }
        } on Object {
          // Body could not be decoded — leave as null for error responses,
          // but fail for success responses that claim to be JSON.
        }

        // Check status code and throw with decoded body available in `data`.
        try {
          switch (statusCode) {
            case > 499:
              throw ApiClientNetworkException(
                code: 'internal_server_error',
                message: 'Internal server error.',
                statusCode: statusCode,
                data: body,
                responseHeaders: responseHeaders,
              );
            case 401:
              throw ApiClientAuthorizationException(
                code: 'unauthorized_error',
                message: 'User is not authorized.',
                statusCode: statusCode,
                data: body,
                responseHeaders: responseHeaders,
              );
            case 403:
              throw ApiClientClientException(
                code: 'forbidden_error',
                message: 'Access forbidden.',
                statusCode: statusCode,
                data: body,
                responseHeaders: responseHeaders,
              );
            case > 399:
              throw ApiClientClientException(
                code: 'bad_request_error',
                message: 'Bad request.',
                statusCode: statusCode,
                data: body,
                responseHeaders: responseHeaders,
              );
            case > 299:
              throw ApiClientClientException(
                code: 'redirection_error',
                message: 'Request was redirected.',
                statusCode: statusCode,
                data: body,
                responseHeaders: responseHeaders,
              );
            default:
              break;
          }
        } on Object catch (error, stackTrace) {
          throwError(completer, error, stackTrace);
          return;
        }

        // For success responses, ensure we have valid JSON.
        if (body == null) {
          throwError(
            completer,
            ApiClientClientException(
              code: 'invalid_content_type_error',
              message: 'Response content type is not application/json.',
              statusCode: statusCode,
              responseHeaders: responseHeaders,
            ),
            StackTrace.current,
          );
          return;
        }

        // Build the response.
        final response = ApiClientResponse.json(
          body,
          statusCode: statusCode,
          headers: responseHeaders,
          contentLength: streamedResponse.contentLength ?? bytes.length,
          persistentConnection: streamedResponse.persistentConnection,
          request: request,
        );

        // Complete the completer.
        if (!completer.isCompleted) completer.complete(response);
      },
      (error, stackTrace) {
        throwError(completer, error, stackTrace);
      },
    );
    return completer.future;
  }

  return middleware(httpHandler);
}

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
sealed class ApiClientException implements Exception, Localizable {
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

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;
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

  @override
  String localize(AppLocalizations localizations) => localizations.internetRequiredToast;
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

  @override
  String localize(AppLocalizations localizations) => localizations.errorTitle;
}
