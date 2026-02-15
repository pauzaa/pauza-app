import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/modes/select_apps/data/pauza_screen_time_installed_apps_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:rxdart/rxdart.dart';

part 'installed_apps_event.dart';
part 'installed_apps_state.dart';

class InstalledAppsBloc extends Bloc<InstalledAppsEvent, InstalledAppsState> {
  InstalledAppsBloc({
    required InstalledAppsRepository installedAppsRepository,
    Duration debounceDuration = const Duration(milliseconds: 500),
  }) : _installedAppsRepository = installedAppsRepository,
       super(const InstalledAppsState()) {
    on<InstalledAppsRequested>(_onInstalledAppsRequested);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) =>
          events.debounceTime(debounceDuration).switchMap(mapper),
    );
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
    on<AppSelectionToggled>(_onAppSelectionToggled);
    on<CategorySelectionToggled>(_onCategorySelectionToggled);
  }

  final InstalledAppsRepository _installedAppsRepository;

  Future<void> _onInstalledAppsRequested(
    InstalledAppsRequested event,
    Emitter<InstalledAppsState> emit,
  ) async {
    try {
      emit(state.loading());

      switch (kPauzaPlatform) {
        case PauzaPlatform.android:
          final apps = await _installedAppsRepository.getAndroidInstalledApps(
            includeSystemApps: event.includeSystemApps,
            includeIcons: event.includeIcons,
          );
          final normalizedApps = _normalizeApps(apps.toIList());
          emit(
            _buildProjectedState(
              state.copyWith(
                isLoading: false,
                allApps: normalizedApps,
                selectedAppIds: event.initialSelectedAppIds.toISet(),
                searchQuery: '',
                clearSelectedCategoryKey: true,
                clearError: true,
              ),
            ),
          );
        case PauzaPlatform.ios:
          throw UnsupportedError('IoS not supported');
      }
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  FutureOr<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<InstalledAppsState> emit,
  ) {
    emit(_buildProjectedState(state.copyWith(searchQuery: event.searchQuery)));
  }

  void _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<InstalledAppsState> emit,
  ) {
    emit(
      _buildProjectedState(
        state.copyWith(
          selectedCategoryKey: event.categoryKey,
          clearSelectedCategoryKey: event.categoryKey == null,
        ),
      ),
    );
  }

  void _onAppSelectionToggled(
    AppSelectionToggled event,
    Emitter<InstalledAppsState> emit,
  ) {
    final nextSelected = state.selectedAppIds.contains(event.appId)
        ? state.selectedAppIds.remove(event.appId)
        : state.selectedAppIds.add(event.appId);
    emit(state.copyWith(selectedAppIds: nextSelected));
  }

  void _onCategorySelectionToggled(
    CategorySelectionToggled event,
    Emitter<InstalledAppsState> emit,
  ) {
    final categoryApps = state.visibleGroupedApps[event.categoryKey];
    if (categoryApps == null || categoryApps.isEmpty) {
      return;
    }

    final categoryAppIds = categoryApps.map((app) => app.packageId).toISet();

    final isCategoryFullySelected = _isCategoryFullySelected(
      categoryApps,
      state.selectedAppIds,
    );

    final nextSelected = isCategoryFullySelected
        ? state.selectedAppIds.removeAll(categoryAppIds)
        : state.selectedAppIds.addAll(categoryAppIds);

    emit(state.copyWith(selectedAppIds: nextSelected));
  }

  InstalledAppsState _buildProjectedState(InstalledAppsState currentState) {
    final filteredApps = _computeFilteredApps(
      apps: currentState.allApps,
      searchQuery: currentState.searchQuery,
    );

    final availableCategoryKeys = _computeAvailableCategories(filteredApps);

    final selectedCategoryKey =
        availableCategoryKeys.contains(currentState.selectedCategoryKey)
        ? currentState.selectedCategoryKey
        : null;

    final visibleGroupedApps = _computeVisibleGroups(
      apps: filteredApps,
      selectedCategoryKey: selectedCategoryKey,
    );

    return currentState.copyWith(
      selectedCategoryKey: selectedCategoryKey,
      clearSelectedCategoryKey: selectedCategoryKey == null,
      availableCategoryKeys: availableCategoryKeys,
      visibleGroupedApps: visibleGroupedApps,
    );
  }

  IList<AndroidAppInfo> _normalizeApps(IList<AndroidAppInfo> apps) {
    final sortedApps = apps.toList(growable: false)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sortedApps.toIList();
  }

  IList<AndroidAppInfo> _computeFilteredApps({
    required IList<AndroidAppInfo> apps,
    required String searchQuery,
  }) {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return apps;
    }

    return apps
        .where(
          (app) =>
              app.name.toLowerCase().contains(normalizedQuery) ||
              app.packageId.value.toLowerCase().contains(normalizedQuery),
        )
        .toIList();
  }

  IList<String> _computeAvailableCategories(IList<AndroidAppInfo> apps) {
    final grouped = groupBy(apps, (app) => app.category ?? _otherCategoryKey);
    final categories = grouped.keys.toList(growable: false)
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories.toIList();
  }

  Map<String, IList<AndroidAppInfo>> _computeVisibleGroups({
    required IList<AndroidAppInfo> apps,
    required String? selectedCategoryKey,
  }) {
    final grouped = groupBy(
      apps,
      (app) => app.category ?? _otherCategoryKey,
    ).map((key, value) => MapEntry(key, value.toIList()));

    if (selectedCategoryKey == null) {
      final sortedKeys = grouped.keys.toList(growable: false)
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      return {for (final key in sortedKeys) key: grouped[key]!};
    }

    final selectedItems = grouped[selectedCategoryKey];
    if (selectedItems == null) {
      return const <String, IList<AndroidAppInfo>>{};
    }

    return <String, IList<AndroidAppInfo>>{selectedCategoryKey: selectedItems};
  }

  bool _isCategoryFullySelected(
    IList<AndroidAppInfo> categoryApps,
    ISet<AppIdentifier> selectedAppIds,
  ) {
    return categoryApps.every((app) => selectedAppIds.contains(app.packageId));
  }
}

const String _otherCategoryKey = 'Other';
