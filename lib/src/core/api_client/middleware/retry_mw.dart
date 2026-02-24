import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:pauza/src/core/api_client/api_client.dart';

/// A function that determines whether a request should be retried based on the [error].
typedef RetryOn = bool Function(Object error);

/// A function that calculates the delay before the next retry attempt.
/// It receives the [retryCount] (e.g., 1 for the first retry).
typedef RetryDelay = Duration Function(int retryCount);

/// A default [RetryOn] implementation that only retries on [ApiClientNetworkException].
///
/// This is a safe default because retrying on client-side errors (like 400 Bad Request)
/// or authorization errors (401/403) is usually pointless as they will likely fail again.
bool _defaultRetryOn(Object error) => error is ApiClientNetworkException;

/// A default [RetryDelay] implementation that uses exponential backoff with jitter.
///
/// Formula: `(2^retryCount * 100ms) + random_jitter`
///
/// Example delays:
/// - 1st retry: ~200ms
/// - 2nd retry: ~400ms
/// - 3rd retry: ~800ms
///
/// Jitter adds a small random delay to prevent multiple clients from retrying in sync.
Duration _defaultRetryDelay(int retryCount) {
  final random = Random();
  final backoff = Duration(milliseconds: 100 * pow(2, retryCount).toInt());
  final jitter = Duration(milliseconds: random.nextInt(100));
  return backoff + jitter;
}

/// A middleware that retries failed requests.
///
/// **Important**: Retries re-send the same [ApiClientRequest] object, so they
/// are only safe for buffered body types ([Request], [MultipartRequest]).
/// [StreamedRequest] bodies cannot be retried because the underlying stream is
/// consumed on the first attempt.
///
/// This middleware is highly configurable to control which errors trigger a retry,
/// how many times to retry, and how long to wait between attempts.
@immutable
class ApiClientRetryMiddleware implements ApiClientMiddleware {
  /// Creates a new [ApiClientRetryMiddleware].
  const ApiClientRetryMiddleware({this.maxRetries = 3, RetryOn? retryOn, RetryDelay? delay})
    : _retryOn = retryOn ?? _defaultRetryOn,
      _delay = delay ?? _defaultRetryDelay;

  /// The maximum number of retry attempts.
  final int maxRetries;

  /// A function that determines whether a request should be retried.
  final RetryOn _retryOn;

  /// A function that calculates the delay before the next retry.
  final RetryDelay _delay;

  @override
  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    for (var i = 0; i <= maxRetries; i++) {
      try {
        // Attempt the request by calling the next handler in the chain.
        final response = await innerHandler(request, context);
        return response;
      } catch (error) {
        // If it's the last attempt or the error is not retry-able, rethrow.
        if (i == maxRetries || !_retryOn(error)) {
          rethrow;
        }

        // Calculate and wait for the delay before the next attempt.
        final retryCount = i + 1;
        final delayDuration = _delay(retryCount);
        await Future<void>.delayed(delayDuration);
      }
    }
    // This line is theoretically unreachable due to the rethrow logic,
    // but it's required to satisfy the function's return type.
    throw StateError('Retry logic finished without returning or rethrowing.');
  };
}
