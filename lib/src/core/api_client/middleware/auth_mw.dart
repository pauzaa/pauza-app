import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:pauza/src/core/api_client/api_client.dart';

/// A function that asynchronously retrieves an authentication token.
/// It should return `null` if no token is available.
typedef TokenProvider = Future<String?> Function();

/// A function that attempts to refresh an authentication token.
/// It receives the [ApiClientAuthorizationException] that triggered the refresh attempt.
/// It should return the new token, or `null` if refreshing fails.
typedef TokenRefresher = Future<String?> Function(ApiClientAuthorizationException error);

/// A function that builds the authorization header map from a given token.
typedef AuthHeaderBuilder = Map<String, String> Function(String token);

/// The default implementation for building an authorization header.
/// Creates a `{'Authorization': 'Bearer <token>'}` map.
Map<String, String> _defaultHeaderBuilder(String token) => {'Authorization': 'Bearer $token'};

/// A middleware that injects an authentication token into requests and
/// can automatically handle token refresh logic.
@immutable
class ApiClientAuthMiddleware implements ApiClientMiddleware {
  /// Creates a new [ApiClientAuthMiddleware].
  ///
  /// - [tokenProvider]: A required function to get the current auth token.
  /// - [tokenRefresher]: An optional function to refresh an expired token.
  /// - [headerBuilder]: An optional function to customize the auth header.
  const ApiClientAuthMiddleware({required this.tokenProvider, this.tokenRefresher, AuthHeaderBuilder? headerBuilder})
    : _headerBuilder = headerBuilder ?? _defaultHeaderBuilder;

  /// The function that provides the current access token.
  final TokenProvider tokenProvider;

  /// The function that refreshes the access token.
  final TokenRefresher? tokenRefresher;

  /// The function that builds the authorization header.
  final AuthHeaderBuilder _headerBuilder;

  /// Context key used to bypass auth header injection and token refresh.
  static const skipAuthKey = 'skipAuth';

  @override
  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    if (context[skipAuthKey] == true) return innerHandler(request, context);

    // 1. Get the initial token and add it to the request.
    final initialToken = await tokenProvider();
    var authorizedRequest = request;
    if (initialToken != null) {
      final authHeaders = _headerBuilder(initialToken);
      // Create a new request with the added headers.
      // It's important not to mutate the original request.
      authorizedRequest = ApiClientRequest(_cloneRequest(request)..headers.addAll(authHeaders));
    }

    try {
      // 2. Attempt the request with the token.
      return await innerHandler(authorizedRequest, context);
    } on ApiClientAuthorizationException catch (error) {
      // 3. If it fails with an auth error, attempt to refresh the token.
      final refresher = tokenRefresher;
      if (refresher == null) {
        rethrow; // No refresher provided, so rethrow the original error.
      }

      final newToken = await refresher(error);
      if (newToken == null) {
        rethrow; // Token refresh failed, so rethrow.
      }

      // 4. If refresh is successful, retry the request with the new token.
      final newAuthHeaders = _headerBuilder(newToken);
      final retriedRequest = ApiClientRequest(_cloneRequest(authorizedRequest)..headers.addAll(newAuthHeaders));
      return await innerHandler(retriedRequest, context);
    }
  };

  /// Clones a [BaseRequest] to allow for modification.
  /// This is necessary because the request object is often immutable after creation.
  static BaseRequest _cloneRequest(ApiClientRequest request) {
    if (request case final MultipartRequest original) {
      final newRequest = MultipartRequest(original.method, original.url)
        ..fields.addAll((original).fields)
        ..files.addAll((original).files)
        ..headers.addAll(original.headers)
        ..persistentConnection = original.persistentConnection
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects;
      return newRequest;
    }

    if (request case final Request original) {
      final newRequest = Request(original.method, original.url)
        ..bodyBytes = (original).bodyBytes
        ..encoding = (original).encoding
        ..headers.addAll(original.headers)
        ..persistentConnection = original.persistentConnection
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects;
      return newRequest;
    }

    if (request is StreamedRequest) {
      throw UnsupportedError(
        'Cloning http.StreamedRequest is not supported. '
        'Due to limitations in the http package, a request body stream cannot be '
        'read after the request is created. Therefore, the AuthMiddleware cannot '
        'clone it to add an authorization header.',
      );
    }

    throw UnsupportedError(
      'Unsupported request type: ${request.runtimeType}. '
      'The request must be an http.Request or http.MultipartRequest.',
    );
  }
}
