part of 'installed_apps_bloc.dart';

sealed class InstalledAppsEvent extends Equatable {
  const InstalledAppsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class InstalledAppsRequested extends InstalledAppsEvent {
  const InstalledAppsRequested({
    this.includeSystemApps = true,
    this.includeIcons = true,
  });

  final bool includeSystemApps;
  final bool includeIcons;

  @override
  List<Object?> get props => <Object?>[includeSystemApps, includeIcons];
}

final class SearchQueryChanged extends InstalledAppsEvent {
  const SearchQueryChanged({required this.searchQuery});

  final String searchQuery;

  @override
  List<Object?> get props => <Object?>[searchQuery];
}

final class CategoryFilterChanged extends InstalledAppsEvent {
  const CategoryFilterChanged({required this.categoryKey});

  final String? categoryKey;

  @override
  List<Object?> get props => <Object?>[categoryKey];
}
