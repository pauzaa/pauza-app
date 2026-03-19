import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_dto.dart';
import 'package:pauza/src/features/leaderboard/data/leaderboard_remote_data_source.dart';

abstract interface class LeaderboardRepository {
  Future<LeaderboardDto> fetchStreakLeaderboard({int page, int limit, bool skipCache});

  Future<LeaderboardDto> fetchFocusTimeLeaderboard({int page, int limit, bool skipCache});
}

final class LeaderboardRepositoryImpl implements LeaderboardRepository {
  const LeaderboardRepositoryImpl({required LeaderboardRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final LeaderboardRemoteDataSource _remoteDataSource;

  @override
  Future<LeaderboardDto> fetchStreakLeaderboard({int page = 1, int limit = 20, bool skipCache = false}) async {
    try {
      return await _remoteDataSource.fetchStreakLeaderboard(page: page, limit: limit, skipCache: skipCache);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<LeaderboardDto> fetchFocusTimeLeaderboard({int page = 1, int limit = 20, bool skipCache = false}) async {
    try {
      return await _remoteDataSource.fetchFocusTimeLeaderboard(page: page, limit: limit, skipCache: skipCache);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }
}
