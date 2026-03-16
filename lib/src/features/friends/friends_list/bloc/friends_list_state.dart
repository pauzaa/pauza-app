part of 'friends_list_bloc.dart';

final class FriendsListState extends Equatable {
  const FriendsListState({
    required this.isLoading,
    required this.friends,
    required this.friendStats,
    required this.searchQuery,
    this.error,
  });

  const FriendsListState.initial()
    : this(
        isLoading: false,
        friends: const <FriendDto>[],
        friendStats: const <String, FriendStatsDto>{},
        searchQuery: '',
      );

  final bool isLoading;
  final List<FriendDto> friends;
  final Map<String, FriendStatsDto> friendStats;
  final String searchQuery;
  final Object? error;

  List<FriendDto> get filteredFriends {
    if (searchQuery.isEmpty) return friends;
    final query = searchQuery.toLowerCase();
    return friends
        .where((f) => f.user.name.toLowerCase().contains(query) || f.user.username.toLowerCase().contains(query))
        .toList(growable: false);
  }

  FriendsListState copyWith({
    bool? isLoading,
    List<FriendDto>? friends,
    Map<String, FriendStatsDto>? friendStats,
    String? searchQuery,
    Object? error,
    bool clearError = false,
  }) {
    return FriendsListState(
      isLoading: isLoading ?? this.isLoading,
      friends: friends ?? this.friends,
      friendStats: friendStats ?? this.friendStats,
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, friends, friendStats, searchQuery, error];
}
