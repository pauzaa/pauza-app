import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_mutation_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_request_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_stats_dto.dart';
import 'package:pauza/src/features/friends/common/model/friends_error.dart';
import 'package:pauza/src/features/friends/common/model/pagination_dto.dart';
import 'package:pauza/src/features/friends/data/friends_remote_data_source.dart';

abstract interface class FriendsRepository {
  Future<({List<FriendDto> friends, PaginationDto pagination})> fetchFriends({
    int page,
    int limit,
  });

  Future<FriendMutationDto> sendRequest({required String username});

  Future<List<FriendRequestDto>> fetchIncomingRequests();

  Future<List<FriendRequestDto>> fetchOutgoingRequests();

  Future<FriendMutationDto> acceptRequest({required String friendshipId});

  Future<void> declineRequest({required String friendshipId});

  Future<void> cancelRequest({required String friendshipId});

  Future<void> removeFriend({required String friendshipId});

  Future<FriendStatsDto> fetchFriendStats({
    required String friendshipId,
    int days,
  });

  Future<List<BasicUserDto>> searchUsers({required String query});
}

final class FriendsRepositoryImpl implements FriendsRepository {
  const FriendsRepositoryImpl({
    required FriendsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final FriendsRemoteDataSource _remoteDataSource;

  @override
  Future<({List<FriendDto> friends, PaginationDto pagination})> fetchFriends({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _remoteDataSource.fetchFriends(page: page, limit: limit);
    } on FriendsError {
      rethrow;
    } on Object catch (e) {
      throw FriendsUnknownError(e);
    }
  }

  @override
  Future<FriendMutationDto> sendRequest({required String username}) async {
    try {
      return await _remoteDataSource.sendRequest(username: username);
    } on FriendsError {
      rethrow;
    } on Object catch (e) {
      throw FriendsUnknownError(e);
    }
  }

  @override
  Future<List<FriendRequestDto>> fetchIncomingRequests() async {
    try {
      return await _remoteDataSource.fetchIncomingRequests();
    } on FriendsError {
      rethrow;
    } on Object catch (e) {
      throw FriendsUnknownError(e);
    }
  }

  @override
  Future<List<FriendRequestDto>> fetchOutgoingRequests() async {
    try {
      return await _remoteDataSource.fetchOutgoingRequests();
    } on FriendsError {
      rethrow;
    } on Object catch (e) {
      throw FriendsUnknownError(e);
    }
  }

  @override
  Future<FriendMutationDto> acceptRequest({
    required String friendshipId,
  }) async {
    try {
      return await _remoteDataSource.acceptRequest(friendshipId: friendshipId);
    } on FriendsError {
      rethrow;
    } on Object catch (e) {
      throw FriendsUnknownError(e);
    }
  }

  @override
  Future<void> declineRequest({required String friendshipId}) async {
    try {
      await _remoteDataSource.declineRequest(friendshipId: friendshipId);
    } on FriendsError {
      rethrow;
    } on Object catch (e) {
      throw FriendsUnknownError(e);
    }
  }

  @override
  Future<void> cancelRequest({required String friendshipId}) async {
    try {
      await _remoteDataSource.cancelRequest(friendshipId: friendshipId);
    } on FriendsError {
      rethrow;
    } on Object catch (e) {
      throw FriendsUnknownError(e);
    }
  }

  @override
  Future<void> removeFriend({required String friendshipId}) async {
    try {
      await _remoteDataSource.removeFriend(friendshipId: friendshipId);
    } on FriendsError {
      rethrow;
    } on Object catch (e) {
      throw FriendsUnknownError(e);
    }
  }

  @override
  Future<FriendStatsDto> fetchFriendStats({
    required String friendshipId,
    int days = 30,
  }) async {
    try {
      return await _remoteDataSource.fetchFriendStats(
        friendshipId: friendshipId,
        days: days,
      );
    } on FriendsError {
      rethrow;
    } on Object catch (e) {
      throw FriendsUnknownError(e);
    }
  }

  @override
  Future<List<BasicUserDto>> searchUsers({required String query}) async {
    try {
      return await _remoteDataSource.searchUsers(query: query);
    } on FriendsError {
      rethrow;
    } on Object catch (e) {
      throw FriendsUnknownError(e);
    }
  }
}
