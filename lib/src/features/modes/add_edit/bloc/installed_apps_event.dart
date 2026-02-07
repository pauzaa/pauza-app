part of 'installed_apps_bloc.dart';

sealed class InstalledAppsEvent extends Equatable {
  const InstalledAppsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class InstalledAppsRequested extends InstalledAppsEvent {
  const InstalledAppsRequested({
    this.includeSystemApps = false,
    this.includeIcons = true,
    this.preSelectedApps,
  });

  final bool includeSystemApps;
  final bool includeIcons;
  final List<IOSAppInfo>? preSelectedApps;

  @override
  List<Object?> get props => <Object?>[includeSystemApps, includeIcons, preSelectedApps];
}
