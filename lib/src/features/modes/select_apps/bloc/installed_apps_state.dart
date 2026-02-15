part of 'installed_apps_bloc.dart';

final class InstalledAppsState extends Equatable {
  const InstalledAppsState({
    this.isLoading = false,
    this.allApps = const IListConst<AndroidAppInfo>(<AndroidAppInfo>[]),
    this.searchQuery = '',
    this.selectedCategoryKey,
    this.selectedAppIds = const ISetConst<AppIdentifier>(<AppIdentifier>{}),
    this.availableCategoryKeys = const IListConst<String>(<String>[]),
    this.visibleGroupedApps = const <String, IList<AndroidAppInfo>>{},
    this.error,
  });

  final bool isLoading;
  final IList<AndroidAppInfo> allApps;
  final String searchQuery;
  final String? selectedCategoryKey;
  final ISet<AppIdentifier> selectedAppIds;
  final IList<String> availableCategoryKeys;
  final Map<String, IList<AndroidAppInfo>> visibleGroupedApps;
  final Object? error;

  int get selectedCount => selectedAppIds.length;

  bool get hasError => error != null;

  bool isAppSelected(AppIdentifier appId) => selectedAppIds.contains(appId);

  bool isCategoryFullySelected(String categoryKey) {
    final categoryApps = visibleGroupedApps[categoryKey];
    if (categoryApps == null || categoryApps.isEmpty) {
      return false;
    }

    return categoryApps.every((app) => selectedAppIds.contains(app.packageId));
  }

  InstalledAppsState loading() => copyWith(isLoading: true, clearError: true);

  InstalledAppsState setError(Object nextError) =>
      copyWith(error: nextError, isLoading: false);

  InstalledAppsState copyWith({
    bool? isLoading,
    IList<AndroidAppInfo>? allApps,
    String? searchQuery,
    String? selectedCategoryKey,
    bool clearSelectedCategoryKey = false,
    ISet<AppIdentifier>? selectedAppIds,
    IList<String>? availableCategoryKeys,
    Map<String, IList<AndroidAppInfo>>? visibleGroupedApps,
    Object? error,
    bool clearError = false,
  }) {
    return InstalledAppsState(
      isLoading: isLoading ?? this.isLoading,
      allApps: allApps ?? this.allApps,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryKey: clearSelectedCategoryKey
          ? null
          : selectedCategoryKey ?? this.selectedCategoryKey,
      selectedAppIds: selectedAppIds ?? this.selectedAppIds,
      availableCategoryKeys:
          availableCategoryKeys ?? this.availableCategoryKeys,
      visibleGroupedApps: visibleGroupedApps ?? this.visibleGroupedApps,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    allApps,
    searchQuery,
    selectedCategoryKey,
    selectedAppIds,
    availableCategoryKeys,
    visibleGroupedApps,
    error,
  ];
}
