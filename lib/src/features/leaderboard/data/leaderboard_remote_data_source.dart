import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/api_client/cache/cache_mw.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_dto.dart';

abstract interface class LeaderboardRemoteDataSource {
  Future<LeaderboardDto> fetchStreakLeaderboard({int page, int limit, bool skipCache});

  Future<LeaderboardDto> fetchFocusTimeLeaderboard({int page, int limit, bool skipCache});
}

final class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  const LeaderboardRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<LeaderboardDto> fetchStreakLeaderboard({int page = 1, int limit = 20, bool skipCache = false}) async {
    try {
      final response = await _apiClient.get(
        '/leaderboard/streaks',
        queryParameters: <String, Object>{'page': page, 'limit': limit},
        context: <String, Object?>{if (skipCache) ApiClientCacheMiddleware.skipCacheKey: true},
      );
      return LeaderboardDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<LeaderboardDto> fetchFocusTimeLeaderboard({int page = 1, int limit = 20, bool skipCache = false}) async {
    try {
      final response = await _apiClient.get(
        '/leaderboard/focus-time',
        queryParameters: <String, Object>{'page': page, 'limit': limit},
        context: <String, Object?>{if (skipCache) ApiClientCacheMiddleware.skipCacheKey: true},
      );
      return LeaderboardDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }
}
