part of 'api_client.dart';

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

        // Clone the request so retries get a fresh (non-finalized) BaseRequest.
        final clonedRequest = _cloneBaseRequest(request._request);

        // Send the cloned request.
        final StreamedResponse streamedResponse;
        try {
          streamedResponse = await internalClient.send(clonedRequest);
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

/// Clones a [BaseRequest] so it can be sent again (e.g. on retry).
/// A [BaseRequest] can only be finalized once; cloning produces a fresh copy.
BaseRequest _cloneBaseRequest(BaseRequest original) {
  if (original is Request) {
    return Request(original.method, original.url)
      ..bodyBytes = original.bodyBytes
      ..encoding = original.encoding
      ..headers.addAll(original.headers)
      ..persistentConnection = original.persistentConnection
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects;
  }

  if (original is MultipartRequest) {
    return MultipartRequest(original.method, original.url)
      ..fields.addAll(original.fields)
      ..files.addAll(original.files)
      ..headers.addAll(original.headers)
      ..persistentConnection = original.persistentConnection
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects;
  }

  // StreamedRequest cannot be cloned (stream is consumed on first read).
  return original;
}
