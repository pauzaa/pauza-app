import 'package:pauza/src/features/leaderboard/common/model/leaderboard_dto.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_error.dart';
import 'package:pauza/src/features/leaderboard/data/leaderboard_remote_data_source.dart';

abstract interface class LeaderboardRepository {
  Future<LeaderboardDto> fetchStreakLeaderboard({int page, int limit});

  Future<LeaderboardDto> fetchFocusTimeLeaderboard({int page, int limit});
}

final class LeaderboardRepositoryImpl implements LeaderboardRepository {
  const LeaderboardRepositoryImpl({
    required LeaderboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final LeaderboardRemoteDataSource _remoteDataSource;

  @override
  Future<LeaderboardDto> fetchStreakLeaderboard({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _remoteDataSource.fetchStreakLeaderboard(
        page: page,
        limit: limit,
      );
    } on LeaderboardError {
      rethrow;
    } on Object catch (e) {
      throw LeaderboardUnknownError(e);
    }
  }

  @override
  Future<LeaderboardDto> fetchFocusTimeLeaderboard({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _remoteDataSource.fetchFocusTimeLeaderboard(
        page: page,
        limit: limit,
      );
    } on LeaderboardError {
      rethrow;
    } on Object catch (e) {
      throw LeaderboardUnknownError(e);
    }
  }
}
