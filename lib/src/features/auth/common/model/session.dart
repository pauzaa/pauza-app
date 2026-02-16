import 'package:flutter/foundation.dart';

@immutable
final class Session {
  const Session({required this.accessToken, required this.refreshToken});

  const Session.empty() : accessToken = '', refreshToken = '';

  final String accessToken;
  final String refreshToken;

  bool get isAuthenticated => accessToken.isNotEmpty;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  factory Session.fromJson(Map<String, Object?> json) {
    return Session(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'Session('
        'accessToken: ${accessToken.isEmpty ? '<empty>' : '<redacted>'}, '
        'refreshToken: ${refreshToken.isEmpty ? '<empty>' : '<redacted>'}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Session &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => Object.hash(accessToken, refreshToken);
}
