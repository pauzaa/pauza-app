import 'dart:async';

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
    on<InitialAppsSearched>(
      _onInitialAppsSearched,
      transformer: (events, mapper) => events.debounceTime(debounceDuration).switchMap(mapper),
    );
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
          emit(state.copyWith(allApps: apps.toIList(), isLoading: false));
        case PauzaPlatform.ios:
          throw UnsupportedError('IoS not supported');
      }
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  FutureOr<void> _onInitialAppsSearched(
    InitialAppsSearched event,
    Emitter<InstalledAppsState> emit,
  ) {
    if (event.searchQuery.isEmpty) {
      emit(state.copyWith(filteredApps: state.allApps));
    } else {
      final filteredApps = state.allApps
          .where(
            (app) =>
                app.name.toLowerCase().contains(event.searchQuery.toLowerCase()) ||
                app.packageId.value.toLowerCase().contains(event.searchQuery.toLowerCase()),
          )
          .toIList();
      emit(state.copyWith(filteredApps: filteredApps));
    }
  }
}
