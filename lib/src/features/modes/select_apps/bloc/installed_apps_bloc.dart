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
      transformer: (events, mapper) => events.debounceTime(debounceDuration).switchMap(mapper),
    );
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
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

  FutureOr<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<InstalledAppsState> emit) {
    emit(_buildProjectedState(state.copyWith(searchQuery: event.searchQuery)));
  }

  void _onCategoryFilterChanged(CategoryFilterChanged event, Emitter<InstalledAppsState> emit) {
    emit(
      _buildProjectedState(
        state.copyWith(
          selectedCategoryKey: event.categoryKey,
          clearSelectedCategoryKey: event.categoryKey == null,
        ),
      ),
    );
  }

  InstalledAppsState _buildProjectedState(InstalledAppsState currentState) {
    final filteredApps = _computeFilteredApps(
      apps: currentState.allApps,
      searchQuery: currentState.searchQuery,
    );

    final availableCategoryKeys = _computeAvailableCategories(filteredApps);

    final selectedCategoryKey = availableCategoryKeys.contains(currentState.selectedCategoryKey)
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
    final categories = grouped.keys.toList(growable: false)..sort(_compareCategoryKeys);
    return categories.toIList();
  }

  int _compareCategoryKeys(String a, String b) {
    if (a == _otherCategoryKey && b == _otherCategoryKey) return 0;
    if (a == _otherCategoryKey) return 1;
    if (b == _otherCategoryKey) return -1;
    return a.toLowerCase().compareTo(b.toLowerCase());
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
      final sortedKeys = grouped.keys.toList(growable: false)..sort(_compareCategoryKeys);

      return {for (final key in sortedKeys) key: grouped[key]!};
    }

    final selectedItems = grouped[selectedCategoryKey];
    if (selectedItems == null) {
      return const <String, IList<AndroidAppInfo>>{};
    }

    return <String, IList<AndroidAppInfo>>{selectedCategoryKey: selectedItems};
  }
}

const String _otherCategoryKey = 'Other';
