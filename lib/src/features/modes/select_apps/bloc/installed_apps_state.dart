part of 'installed_apps_bloc.dart';

final class InstalledAppsState extends Equatable {
  const InstalledAppsState({
    this.isLoading = false,
    this.allApps = const IListConst<AndroidAppInfo>(<AndroidAppInfo>[]),
    this.searchQuery = '',
    this.selectedCategoryKey,
    this.availableCategoryKeys = const IListConst<String>(<String>[]),
    this.visibleGroupedApps = const <String, IList<AndroidAppInfo>>{},
    this.error,
  });

  final bool isLoading;
  final String searchQuery;
  final String? selectedCategoryKey;
  final IList<AndroidAppInfo> allApps;
  final IList<String> availableCategoryKeys;
  final Map<String, IList<AndroidAppInfo>> visibleGroupedApps;
  final Object? error;

  bool get hasError => error != null;

  InstalledAppsState loading() => copyWith(isLoading: true, clearError: true);

  InstalledAppsState setError(Object nextError) => copyWith(error: nextError, isLoading: false);

  InstalledAppsState copyWith({
    bool? isLoading,
    IList<AndroidAppInfo>? allApps,
    String? searchQuery,
    String? selectedCategoryKey,
    bool clearSelectedCategoryKey = false,
    IList<String>? availableCategoryKeys,
    Map<String, IList<AndroidAppInfo>>? visibleGroupedApps,
    Object? error,
    bool clearError = false,
  }) {
    return InstalledAppsState(
      isLoading: isLoading ?? this.isLoading,
      allApps: allApps ?? this.allApps,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryKey: clearSelectedCategoryKey ? null : selectedCategoryKey ?? this.selectedCategoryKey,
      availableCategoryKeys: availableCategoryKeys ?? this.availableCategoryKeys,
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
    availableCategoryKeys,
    visibleGroupedApps,
    error,
  ];
}
