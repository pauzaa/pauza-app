import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/modes/select_apps/data/pauza_screen_time_installed_apps_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

part 'installed_apps_event.dart';
part 'installed_apps_state.dart';

class InstalledAppsBloc extends Bloc<InstalledAppsEvent, InstalledAppsState> {
  InstalledAppsBloc({required InstalledAppsRepository installedAppsRepository})
    : _installedAppsRepository = installedAppsRepository,
      super(const InstalledAppsState()) {
    on<InstalledAppsRequested>(_onInstalledAppsRequested);
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
          emit(state.copyWith(items: apps, isLoading: false));
        case PauzaPlatform.ios:
          throw UnsupportedError('IoS not supported');
      }
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }
}
