import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_mutation_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_request_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_stats_dto.dart';
import 'package:pauza/src/features/friends/common/model/pagination_dto.dart';
import 'package:pauza/src/features/friends/data/friends_remote_data_source.dart';

abstract interface class FriendsRepository {
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

final class FriendsRepositoryImpl implements FriendsRepository {
  const FriendsRepositoryImpl({required FriendsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final FriendsRemoteDataSource _remoteDataSource;

  @override
  Future<({List<FriendDto> friends, PaginationDto pagination})> fetchFriends({
    int page = 1,
    int limit = 20,
    bool skipCache = false,
  }) async {
    try {
      return await _remoteDataSource.fetchFriends(page: page, limit: limit, skipCache: skipCache);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<FriendMutationDto> sendRequest({required String username}) async {
    try {
      return await _remoteDataSource.sendRequest(username: username);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<List<FriendRequestDto>> fetchIncomingRequests({bool skipCache = false}) async {
    try {
      return await _remoteDataSource.fetchIncomingRequests(skipCache: skipCache);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<List<FriendRequestDto>> fetchOutgoingRequests({bool skipCache = false}) async {
    try {
      return await _remoteDataSource.fetchOutgoingRequests(skipCache: skipCache);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<FriendMutationDto> acceptRequest({required String friendshipId}) async {
    try {
      return await _remoteDataSource.acceptRequest(friendshipId: friendshipId);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<void> declineRequest({required String friendshipId}) async {
    try {
      await _remoteDataSource.declineRequest(friendshipId: friendshipId);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<void> cancelRequest({required String friendshipId}) async {
    try {
      await _remoteDataSource.cancelRequest(friendshipId: friendshipId);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<void> removeFriend({required String friendshipId}) async {
    try {
      await _remoteDataSource.removeFriend(friendshipId: friendshipId);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<FriendStatsDto> fetchFriendStats({required String friendshipId, int days = 30}) async {
    try {
      return await _remoteDataSource.fetchFriendStats(friendshipId: friendshipId, days: days);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<List<BasicUserDto>> searchUsers({required String query}) async {
    try {
      return await _remoteDataSource.searchUsers(query: query);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }
}
