import 'dart:developer' as developer;

import 'package:meta/meta.dart';

import 'package:pauza/src/core/api_client/api_client.dart';

typedef Logger = void Function(String msg);

typedef ErrorLogger = void Function(String msg, Object? error, StackTrace stackTrace);

void _defaultLogger(String msg) => developer.log(msg, name: 'http', time: DateTime.now(), level: 300);

void _defaultErrorLogger(String msg, Object? error, StackTrace stackTrace) =>
    developer.log(msg, name: 'http', time: DateTime.now(), level: 900, error: error, stackTrace: stackTrace);

@immutable
class ApiClientLoggerMiddleware implements ApiClientMiddleware {
  const ApiClientLoggerMiddleware({
    Logger? onRequest,
    Logger? onResponse,
    ErrorLogger? onError,
    this.logRequest = false,
    this.logResponse = true,
    this.logError = true,
  }) : _onRequest = onRequest ?? _defaultLogger,
       _onResponse = onResponse ?? _defaultLogger,
       _onError = onError ?? _defaultErrorLogger;

  final Logger _onRequest;
  final Logger _onResponse;
  final ErrorLogger _onError;

  final bool logRequest;
  final bool logResponse;
  final bool logError;

  @override
  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (logRequest) {
        _onRequest('[${request.method}] ${request.url.path}');
      }
      final response = await innerHandler(request, context);
      if (logResponse) {
        _onResponse('[${request.method}] ${request.url.path} -> ok | ${stopwatch.elapsedMilliseconds}ms');
      }
      return response;
    } on ApiClientException catch (error, stackTrace) {
      if (logError) {
        _onError(
          '[${request.method}] ${request.url.path} -> failed with ${error.statusCode} code | ${stopwatch.elapsedMilliseconds}ms\n'
          'Response body: ${error.data}',
          error,
          stackTrace,
        );
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  };
}
