import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_dto.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_error.dart';

abstract interface class LeaderboardRemoteDataSource {
  Future<LeaderboardDto> fetchStreakLeaderboard({int page, int limit});

  Future<LeaderboardDto> fetchFocusTimeLeaderboard({int page, int limit});
}

final class LeaderboardRemoteDataSourceImpl
    implements LeaderboardRemoteDataSource {
  const LeaderboardRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<LeaderboardDto> fetchStreakLeaderboard({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/leaderboard/streaks',
        queryParameters: <String, Object>{'page': page, 'limit': limit},
      );
      return LeaderboardDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<LeaderboardDto> fetchFocusTimeLeaderboard({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/leaderboard/focus-time',
        queryParameters: <String, Object>{'page': page, 'limit': limit},
      );
      return LeaderboardDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw _mapException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  static LeaderboardError _mapException(ApiClientException e) {
    switch (e) {
      case ApiClientAuthorizationException():
        return const LeaderboardUnauthorizedError();
      case ApiClientNetworkException():
        return const LeaderboardNetworkError();
      case ApiClientClientException():
        return LeaderboardUnknownError(e);
    }
  }
}
