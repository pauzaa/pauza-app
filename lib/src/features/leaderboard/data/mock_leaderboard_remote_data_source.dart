import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';
import 'package:pauza/src/features/friends/common/model/pagination_dto.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_dto.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_entry_dto.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_rank_dto.dart';
import 'package:pauza/src/features/leaderboard/data/leaderboard_remote_data_source.dart';

final class MockLeaderboardRemoteDataSource
    implements LeaderboardRemoteDataSource {
  const MockLeaderboardRemoteDataSource();

  @override
  Future<LeaderboardDto> fetchStreakLeaderboard({
    int page = 1,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return LeaderboardDto(
      entries: <LeaderboardEntryDto>[
        for (var i = 0; i < _mockUsers.length; i++)
          LeaderboardEntryDto(
            rank: i + 1,
            user: _mockUsers[i],
            currentStreakDays: _streakDays[i],
          ),
      ],
      myRank: const LeaderboardRankDto(rank: 5, currentStreakDays: 12),
      pagination: const PaginationDto(page: 1, limit: 20, total: 10),
    );
  }

  @override
  Future<LeaderboardDto> fetchFocusTimeLeaderboard({
    int page = 1,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return LeaderboardDto(
      entries: <LeaderboardEntryDto>[
        for (var i = 0; i < _mockUsers.length; i++)
          LeaderboardEntryDto(
            rank: i + 1,
            user: _mockUsers[i],
            totalFocusTimeMs: _focusTimeMs[i],
          ),
      ],
      myRank: const LeaderboardRankDto(rank: 5, totalFocusTimeMs: 5400000),
      pagination: const PaginationDto(page: 1, limit: 20, total: 10),
    );
  }
}

const _mockUsers = <BasicUserDto>[
  BasicUserDto(id: '1', name: 'Alice Johnson', username: 'alice_j'),
  BasicUserDto(id: '2', name: 'Bob Smith', username: 'bobsmith'),
  BasicUserDto(id: '3', name: 'Charlie Lee', username: 'charlie'),
  BasicUserDto(id: '4', name: 'Diana Park', username: 'diana_p'),
  BasicUserDto(id: '5', name: 'Alisher', username: 'alisher'),
  BasicUserDto(id: '6', name: 'Fiona Chen', username: 'fiona_c'),
  BasicUserDto(id: '7', name: 'George Kim', username: 'gkim'),
  BasicUserDto(id: '8', name: 'Hannah Davis', username: 'hannah'),
  BasicUserDto(id: '9', name: 'Ivan Petrov', username: 'ivan_p'),
  BasicUserDto(id: '10', name: 'Julia Wang', username: 'julia_w'),
];

const _streakDays = <int>[45, 38, 31, 25, 12, 10, 8, 6, 4, 2];

const _focusTimeMs = <int>[
  36000000, // 10h
  28800000, // 8h
  21600000, // 6h
  14400000, // 4h
  5400000, // 1h 30m
  3600000, // 1h
  2700000, // 45m
  1800000, // 30m
  900000, // 15m
  300000, // 5m
];
