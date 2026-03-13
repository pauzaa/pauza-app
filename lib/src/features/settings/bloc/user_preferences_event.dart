part of 'user_preferences_bloc.dart';

sealed class UserPreferencesEvent extends Equatable {
  const UserPreferencesEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class UserPreferencesStarted extends UserPreferencesEvent {
  const UserPreferencesStarted();
}

final class UserPreferencesPushToggled extends UserPreferencesEvent {
  const UserPreferencesPushToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

final class UserPreferencesLeaderboardToggled extends UserPreferencesEvent {
  const UserPreferencesLeaderboardToggled({required this.visible});

  final bool visible;

  @override
  List<Object?> get props => <Object?>[visible];
}
