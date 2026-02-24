import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:pauza/src/core/api_client/api_client.dart';

// TODO: Not yet registered in PauzaDependencies — wire up when needed.

/// A function that asynchronously retrieves the current locale/language code.
/// It should return `null` if no language is available.
typedef LangProvider = Future<String?> Function();

/// A function that builds the `Accept-Language` header map from a given language code.
typedef LangHeaderBuilder = Map<String, String> Function(String lang);

/// The default implementation for building the language header.
/// Creates a `{'Accept-Language': '<lang>'}` map.
Map<String, String> _defaultHeaderBuilder(String lang) => {'Accept-Language': lang};

/// A middleware that injects an `Accept-Language` header into requests.
@immutable
class ApiClientLangMiddleware implements ApiClientMiddleware {
  /// Creates a new [ApiClientLangMiddleware].
  ///
  /// - [langProvider]: A required function to get the current language code.
  /// - [headerBuilder]: An optional function to customize the language header.
  const ApiClientLangMiddleware({required this.langProvider, LangHeaderBuilder? headerBuilder})
    : _headerBuilder = headerBuilder ?? _defaultHeaderBuilder;

  /// The function that provides the current language code.
  final LangProvider langProvider;

  /// The function that builds the language header.
  final LangHeaderBuilder _headerBuilder;

  @override
  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final lang = await langProvider();
    if (lang == null) return innerHandler(request, context);

    final langHeaders = _headerBuilder(lang);
    final modifiedRequest = ApiClientRequest(_cloneRequest(request)..headers.addAll(langHeaders));
    return innerHandler(modifiedRequest, context);
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
