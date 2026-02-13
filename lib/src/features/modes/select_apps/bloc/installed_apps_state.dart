part of 'installed_apps_bloc.dart';

final class InstalledAppsState extends Equatable {
  const InstalledAppsState({
    this.isLoading = false,
    this.filteredApps = const IList<AndroidAppInfo>.empty(),
    this.allApps = const IList<AndroidAppInfo>.empty(),
    this.error,
  });

  final bool isLoading;
  final IList<AndroidAppInfo> allApps;
  final IList<AndroidAppInfo> filteredApps;
  final Object? error;

  IList<AndroidAppInfo> get effectiveApps => filteredApps.isEmpty ? allApps : filteredApps;

  bool get hasError => error != null;

  InstalledAppsState loading() => copyWith(isLoading: true);

  InstalledAppsState setError(Object error) => copyWith(error: error, isLoading: false);

  InstalledAppsState copyWith({
    bool? isLoading,
    IList<AndroidAppInfo>? allApps,
    IList<AndroidAppInfo>? filteredApps,
    Object? error,
  }) {
    return InstalledAppsState(
      isLoading: isLoading ?? this.isLoading,
      allApps: allApps ?? this.allApps,
      filteredApps: filteredApps ?? this.filteredApps,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, allApps, filteredApps, error];
}
