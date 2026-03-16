import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_mutation_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_request_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_stats_dto.dart';
import 'package:pauza/src/features/friends/common/model/friends_error.dart';
import 'package:pauza/src/features/friends/common/model/pagination_dto.dart';

abstract interface class FriendsRemoteDataSource {
  Future<({List<FriendDto> friends, PaginationDto pagination})> fetchFriends({int page, int limit});

  Future<FriendMutationDto> sendRequest({required String username});

  Future<List<FriendRequestDto>> fetchIncomingRequests();

  Future<List<FriendRequestDto>> fetchOutgoingRequests();

  Future<FriendMutationDto> acceptRequest({required String friendshipId});

  Future<void> declineRequest({required String friendshipId});

  Future<void> cancelRequest({required String friendshipId});

  Future<void> removeFriend({required String friendshipId});

  Future<FriendStatsDto> fetchFriendStats({required String friendshipId, int days});

  Future<List<BasicUserDto>> searchUsers({required String query});
}

final class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  const FriendsRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<({List<FriendDto> friends, PaginationDto pagination})> fetchFriends({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/friends',
        queryParameters: <String, Object>{'page': page, 'limit': limit},
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
      throw FriendsError.fromApiException(e);
    }
  }

  @override
  Future<FriendMutationDto> sendRequest({required String username}) async {
    try {
      final response = await _apiClient.post('/api/v1/friends/request', body: <String, Object?>{'username': username});
      return FriendMutationDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw FriendsError.fromApiException(e);
    }
  }

  @override
  Future<List<FriendRequestDto>> fetchIncomingRequests() async {
    try {
      final response = await _apiClient.get('/api/v1/friends/requests/incoming');
      final rawRequests = response.data!['requests'] as List<Object?>?;
      return rawRequests
              ?.map((e) => FriendRequestDto.fromJson(e as Map<String, Object?>? ?? const {}))
              .toList(growable: false) ??
          const [];
    } on ApiClientException catch (e) {
      throw FriendsError.fromApiException(e);
    }
  }

  @override
  Future<List<FriendRequestDto>> fetchOutgoingRequests() async {
    try {
      final response = await _apiClient.get('/api/v1/friends/requests/outgoing');
      final rawRequests = response.data!['requests'] as List<Object?>?;
      return rawRequests
              ?.map((e) => FriendRequestDto.fromJson(e as Map<String, Object?>? ?? const {}))
              .toList(growable: false) ??
          const [];
    } on ApiClientException catch (e) {
      throw FriendsError.fromApiException(e);
    }
  }

  @override
  Future<FriendMutationDto> acceptRequest({required String friendshipId}) async {
    try {
      final response = await _apiClient.post('/api/v1/friends/requests/$friendshipId/accept');
      return FriendMutationDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw FriendsError.fromApiException(e);
    }
  }

  @override
  Future<void> declineRequest({required String friendshipId}) async {
    try {
      await _apiClient.post('/api/v1/friends/requests/$friendshipId/decline');
    } on ApiClientException catch (e) {
      throw FriendsError.fromApiException(e);
    }
  }

  @override
  Future<void> cancelRequest({required String friendshipId}) async {
    try {
      await _apiClient.post('/api/v1/friends/requests/$friendshipId/cancel');
    } on ApiClientException catch (e) {
      throw FriendsError.fromApiException(e);
    }
  }

  @override
  Future<void> removeFriend({required String friendshipId}) async {
    try {
      await _apiClient.delete('/api/v1/friends/$friendshipId');
    } on ApiClientException catch (e) {
      throw FriendsError.fromApiException(e);
    }
  }

  @override
  Future<FriendStatsDto> fetchFriendStats({required String friendshipId, int days = 30}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/friends/$friendshipId/stats',
        queryParameters: <String, Object>{'days': days},
      );
      return FriendStatsDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw FriendsError.fromApiException(e);
    }
  }

  @override
  Future<List<BasicUserDto>> searchUsers({required String query}) async {
    try {
      final response = await _apiClient.get('/api/v1/friends/search', queryParameters: <String, Object>{'q': query});
      final rawUsers = response.data!['users'] as List<Object?>?;
      return rawUsers
              ?.map((e) => BasicUserDto.fromJson(e as Map<String, Object?>? ?? const {}))
              .toList(growable: false) ??
          const [];
    } on ApiClientException catch (e) {
      throw FriendsError.fromApiException(e);
    }
  }
}
