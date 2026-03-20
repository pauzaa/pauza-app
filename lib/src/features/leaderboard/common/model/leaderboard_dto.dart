import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/friends/common/model/pagination_dto.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_entry_dto.dart';
import 'package:pauza/src/features/leaderboard/common/model/leaderboard_rank_dto.dart';

@immutable
final class LeaderboardDto {
  const LeaderboardDto({required this.entries, required this.myRank, required this.pagination});

  factory LeaderboardDto.fromJson(Map<String, Object?> json) {
    final rawEntries = json['entries'] as List<Object?>?;
    return LeaderboardDto(
      entries:
          rawEntries
              ?.map((e) => LeaderboardEntryDto.fromJson(e as Map<String, Object?>? ?? const {}))
              .toList(growable: false) ??
          const [],
      myRank: LeaderboardRankDto.fromJson(json['my_rank'] as Map<String, Object?>? ?? const {}),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, Object?>? ?? const {}),
    );
  }

  final List<LeaderboardEntryDto> entries;
  final LeaderboardRankDto myRank;
  final PaginationDto pagination;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardDto &&
          _listEquals(entries, other.entries) &&
          myRank == other.myRank &&
          pagination == other.pagination;

  @override
  int get hashCode => Object.hash(Object.hashAll(entries), myRank, pagination);

  @override
  String toString() =>
      'LeaderboardDto(entries: $entries, myRank: $myRank, '
      'pagination: $pagination)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
