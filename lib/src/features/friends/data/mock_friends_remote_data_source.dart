import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';
import 'package:pauza/src/features/friends/common/model/daily_trend_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_mutation_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_request_dto.dart';
import 'package:pauza/src/features/friends/common/model/friend_stats_dto.dart';
import 'package:pauza/src/features/friends/common/model/pagination_dto.dart';
import 'package:pauza/src/features/friends/data/friends_remote_data_source.dart';

final class MockFriendsRemoteDataSource implements FriendsRemoteDataSource {
  const MockFriendsRemoteDataSource();

  @override
  Future<({List<FriendDto> friends, PaginationDto pagination})> fetchFriends({
    int page = 1,
    int limit = 20,
    bool skipCache = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return (
      friends: <FriendDto>[
        for (var i = 0; i < _friendUsers.length; i++)
          FriendDto(friendshipId: 'fr_${i + 1}', user: _friendUsers[i], since: DateTime.utc(2025, 12 - i, 10 + i)),
      ],
      pagination: PaginationDto(page: 1, limit: 20, total: _friendUsers.length),
    );
  }

  @override
  Future<List<FriendRequestDto>> fetchIncomingRequests({bool skipCache = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return <FriendRequestDto>[
      FriendRequestDto(
        friendshipId: 'req_in_1',
        user: const BasicUserDto(id: '11', name: 'Kevin Brown', username: 'kevin_b'),
        createdAt: _jan15,
      ),
      FriendRequestDto(
        friendshipId: 'req_in_2',
        user: const BasicUserDto(id: '12', name: 'Laura Martinez', username: 'laura_m'),
        createdAt: _jan18,
      ),
    ];
  }

  @override
  Future<List<FriendRequestDto>> fetchOutgoingRequests({bool skipCache = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return <FriendRequestDto>[
      FriendRequestDto(
        friendshipId: 'req_out_1',
        user: const BasicUserDto(id: '13', name: 'Michael Yang', username: 'mike_y'),
        createdAt: _jan20,
      ),
    ];
  }

  @override
  Future<FriendMutationDto> sendRequest({required String username}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const FriendMutationDto(friendshipId: 'fr_new', status: 'pending');
  }

  @override
  Future<FriendMutationDto> acceptRequest({required String friendshipId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return FriendMutationDto(friendshipId: friendshipId, status: 'accepted');
  }

  @override
  Future<void> declineRequest({required String friendshipId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> cancelRequest({required String friendshipId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> removeFriend({required String friendshipId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<FriendStatsDto> fetchFriendStats({required String friendshipId, int days = 7}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return FriendStatsDto(
      user: _friendUsers.first,
      currentStreakDays: 14,
      longestStreakDays: 31,
      totalFocusTimeMs: 7200000, // 2h
      focusTimeTodayMs: 2700000, // 45m
      dailyTrends: const <DailyTrendDto>[
        DailyTrendDto(localDay: '2026-03-16', effectiveMs: 3600000, qualified: true, sessionCount: 3),
        DailyTrendDto(localDay: '2026-03-17', effectiveMs: 2700000, qualified: true, sessionCount: 2),
        DailyTrendDto(localDay: '2026-03-18', effectiveMs: 4500000, qualified: true, sessionCount: 4),
        DailyTrendDto(localDay: '2026-03-19', effectiveMs: 1800000, qualified: true, sessionCount: 1),
        DailyTrendDto(localDay: '2026-03-20', effectiveMs: 5400000, qualified: true, sessionCount: 5),
        DailyTrendDto(localDay: '2026-03-21', effectiveMs: 3200000, qualified: true, sessionCount: 3),
        DailyTrendDto(localDay: '2026-03-22', effectiveMs: 2700000, qualified: true, sessionCount: 2),
      ],
    );
  }

  @override
  Future<List<BasicUserDto>> searchUsers({required String query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const <BasicUserDto>[
      BasicUserDto(id: '14', name: 'Sarah Connor', username: 'sarah_c'),
      BasicUserDto(id: '15', name: 'Sam Wilson', username: 'sam_w'),
      BasicUserDto(id: '16', name: 'Sandra Lee', username: 'sandra_l'),
    ];
  }
}

/// First 6 users from the shared mock list, used as established friends.
const _friendUsers = <BasicUserDto>[
  BasicUserDto(id: '1', name: 'Alice Johnson', username: 'alice_j'),
  BasicUserDto(id: '2', name: 'Bob Smith', username: 'bobsmith'),
  BasicUserDto(id: '3', name: 'Charlie Lee', username: 'charlie'),
  BasicUserDto(id: '4', name: 'Diana Park', username: 'diana_p'),
  BasicUserDto(id: '6', name: 'Fiona Chen', username: 'fiona_c'),
  BasicUserDto(id: '7', name: 'George Kim', username: 'gkim'),
];

final _jan15 = DateTime.utc(2026, 1, 15);
final _jan18 = DateTime.utc(2026, 1, 18);
final _jan20 = DateTime.utc(2026, 1, 20);
