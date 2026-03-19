import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/api_client/cache/cache_mw.dart';
import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_mutation_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_request_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_stats_dto.dart';
import 'package:pauza/src/features/friends/common/model/pagination_dto.dart';

abstract interface class FriendsRemoteDataSource {
  Future<({List<FriendDto> friends, PaginationDto pagination})> fetchFriends({int page, int limit, bool skipCache});

  Future<FriendMutationDto> sendRequest({required String username});

  Future<List<FriendRequestDto>> fetchIncomingRequests({bool skipCache});

  Future<List<FriendRequestDto>> fetchOutgoingRequests({bool skipCache});

  Future<FriendMutationDto> acceptRequest({required String friendshipId});

  Future<void> declineRequest({required String friendshipId});

  Future<void> cancelRequest({required String friendshipId});

  Future<void> removeFriend({required String friendshipId});

  Future<FriendStatsDto> fetchFriendStats({required String friendshipId, int days});

  Future<List<BasicUserDto>> searchUsers({required String query});
}

final class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  const FriendsRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  static const _invalidatePrefix = '/friends';

  final ApiClient _apiClient;

  @override
  Future<({List<FriendDto> friends, PaginationDto pagination})> fetchFriends({
    int page = 1,
    int limit = 20,
    bool skipCache = false,
  }) async {
    try {
      final response = await _apiClient.get(
        '/friends',
        queryParameters: <String, Object>{'page': page, 'limit': limit},
        context: <String, Object?>{if (skipCache) ApiClientCacheMiddleware.skipCacheKey: true},
      );
      final data = response.data!;
      final rawFriends = data['friends'] as List<Object?>?;
      return (
        friends:
            rawFriends
                ?.map((e) => FriendDto.fromJson(e as Map<String, Object?>? ?? const {}))
                .toList(growable: false) ??
            const [],
        pagination: PaginationDto.fromJson(data['pagination'] as Map<String, Object?>? ?? const {}),
      );
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<FriendMutationDto> sendRequest({required String username}) async {
    try {
      final response = await _apiClient.post(
        '/friends/request',
        body: <String, Object?>{'username': username},
        context: <String, Object?>{ApiClientCacheMiddleware.invalidatePrefixKey: _invalidatePrefix},
      );
      return FriendMutationDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<List<FriendRequestDto>> fetchIncomingRequests({bool skipCache = false}) async {
    try {
      final response = await _apiClient.get(
        '/friends/requests/incoming',
        context: <String, Object?>{if (skipCache) ApiClientCacheMiddleware.skipCacheKey: true},
      );
      final rawRequests = response.data!['requests'] as List<Object?>?;
      return rawRequests
              ?.map((e) => FriendRequestDto.fromJson(e as Map<String, Object?>? ?? const {}))
              .toList(growable: false) ??
          const [];
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<List<FriendRequestDto>> fetchOutgoingRequests({bool skipCache = false}) async {
    try {
      final response = await _apiClient.get(
        '/friends/requests/outgoing',
        context: <String, Object?>{if (skipCache) ApiClientCacheMiddleware.skipCacheKey: true},
      );
      final rawRequests = response.data!['requests'] as List<Object?>?;
      return rawRequests
              ?.map((e) => FriendRequestDto.fromJson(e as Map<String, Object?>? ?? const {}))
              .toList(growable: false) ??
          const [];
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<FriendMutationDto> acceptRequest({required String friendshipId}) async {
    try {
      final response = await _apiClient.post(
        '/friends/requests/$friendshipId/accept',
        context: <String, Object?>{ApiClientCacheMiddleware.invalidatePrefixKey: _invalidatePrefix},
      );
      return FriendMutationDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<void> declineRequest({required String friendshipId}) async {
    try {
      await _apiClient.post(
        '/friends/requests/$friendshipId/decline',
        context: <String, Object?>{ApiClientCacheMiddleware.invalidatePrefixKey: _invalidatePrefix},
      );
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<void> cancelRequest({required String friendshipId}) async {
    try {
      await _apiClient.post(
        '/friends/requests/$friendshipId/cancel',
        context: <String, Object?>{ApiClientCacheMiddleware.invalidatePrefixKey: _invalidatePrefix},
      );
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<void> removeFriend({required String friendshipId}) async {
    try {
      await _apiClient.delete(
        '/friends/$friendshipId',
        context: <String, Object?>{ApiClientCacheMiddleware.invalidatePrefixKey: _invalidatePrefix},
      );
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<FriendStatsDto> fetchFriendStats({required String friendshipId, int days = 7}) async {
    try {
      final response = await _apiClient.get(
        '/friends/$friendshipId/stats',
        queryParameters: <String, Object>{'days': days},
      );
      return FriendStatsDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<List<BasicUserDto>> searchUsers({required String query}) async {
    try {
      final response = await _apiClient.get('/friends/search', queryParameters: <String, Object>{'q': query});
      final rawUsers = response.data!['users'] as List<Object?>?;
      return rawUsers
              ?.map((e) => BasicUserDto.fromJson(e as Map<String, Object?>? ?? const {}))
              .toList(growable: false) ??
          const [];
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }
}
