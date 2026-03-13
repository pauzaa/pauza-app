part of 'user_preferences_bloc.dart';

final class UserPreferencesState extends Equatable {
  const UserPreferencesState({
    this.isLoading = false,
    this.pushEnabled,
    this.leaderboardVisible,
    this.isSavingPush = false,
    this.isSavingLeaderboard = false,
    this.error,
  });

  final bool isLoading;
  final bool? pushEnabled;
  final bool? leaderboardVisible;
  final bool isSavingPush;
  final bool isSavingLeaderboard;
  final Object? error;

  bool get hasData => pushEnabled != null && leaderboardVisible != null;

  UserPreferencesState copyWith({
    bool? isLoading,
    bool? pushEnabled,
    bool? leaderboardVisible,
    bool? isSavingPush,
    bool? isSavingLeaderboard,
    Object? error,
    bool clearError = false,
  }) => UserPreferencesState(
    isLoading: isLoading ?? this.isLoading,
    pushEnabled: pushEnabled ?? this.pushEnabled,
    leaderboardVisible: leaderboardVisible ?? this.leaderboardVisible,
    isSavingPush: isSavingPush ?? this.isSavingPush,
    isSavingLeaderboard: isSavingLeaderboard ?? this.isSavingLeaderboard,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    pushEnabled,
    leaderboardVisible,
    isSavingPush,
    isSavingLeaderboard,
    error,
  ];
}
