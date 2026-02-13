part of 'installed_apps_bloc.dart';

sealed class InstalledAppsEvent extends Equatable {
  const InstalledAppsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class InstalledAppsRequested extends InstalledAppsEvent {
  const InstalledAppsRequested({this.includeSystemApps = false, this.includeIcons = true});

  final bool includeSystemApps;
  final bool includeIcons;

  @override
  List<Object?> get props => <Object?>[includeSystemApps, includeIcons];
}

final class InitialAppsSearched extends InstalledAppsEvent {
  const InitialAppsSearched({required this.searchQuery});
  final String searchQuery;

  @override
  List<Object?> get props => <Object?>[searchQuery];
}
