part of 'installed_apps_bloc.dart';

sealed class InstalledAppsEvent extends Equatable {
  const InstalledAppsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class InstalledAppsRequested extends InstalledAppsEvent {
  const InstalledAppsRequested({
    required this.initialSelectedAppIds,
    this.includeSystemApps = false,
    this.includeIcons = true,
  });

  final ISet<AppIdentifier> initialSelectedAppIds;
  final bool includeSystemApps;
  final bool includeIcons;

  @override
  List<Object?> get props => <Object?>[
    initialSelectedAppIds,
    includeSystemApps,
    includeIcons,
  ];
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

final class AppSelectionToggled extends InstalledAppsEvent {
  const AppSelectionToggled({required this.appId});

  final AppIdentifier appId;

  @override
  List<Object?> get props => <Object?>[appId];
}

final class CategorySelectionToggled extends InstalledAppsEvent {
  const CategorySelectionToggled({required this.categoryKey});

  final String categoryKey;

  @override
  List<Object?> get props => <Object?>[categoryKey];
}
