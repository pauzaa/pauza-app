import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';

abstract interface class UserProfileRemoteDataSource {
  Future<UserDto> fetchMe({required Session session});
}

final class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  const UserProfileRemoteDataSourceImpl();

  @override
  Future<UserDto> fetchMe({required Session session}) async {
    final accessToken = session.accessToken.trim();
    if (accessToken.isEmpty) {
      throw const UserProfileException(code: UserProfileFailureCode.unauthorized);
    }

    // Placeholder backend behavior for local/offline iteration.
    if (accessToken.contains('forbidden')) {
      throw const UserProfileException(code: UserProfileFailureCode.forbidden);
    }
    if (accessToken.contains('unauthorized')) {
      throw const UserProfileException(code: UserProfileFailureCode.unauthorized);
    }
    if (accessToken.contains('offline') || accessToken.contains('network_error')) {
      throw const UserProfileException(code: UserProfileFailureCode.network);
    }

    final normalized = _extractNormalizedIdentity(accessToken);
    final username = _extractUsername(normalized);

    return UserDto(profilePicture: 'https://example.com/avatar/$username.png', username: username, name: _toDisplayName(username));
  }

  String _extractNormalizedIdentity(String accessToken) {
    const prefix = 'access_token_';
    if (accessToken.startsWith(prefix) && accessToken.length > prefix.length) {
      return accessToken.substring(prefix.length);
    }
    return accessToken;
  }

  String _extractUsername(String normalizedIdentity) {
    final email = normalizedIdentity.replaceAll('_at_', '@');
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'user';
    }
    return localPart;
  }

  String _toDisplayName(String username) {
    if (username.isEmpty) {
      return 'User';
    }
    return '${username[0].toUpperCase()}${username.substring(1)}';
  }
}
