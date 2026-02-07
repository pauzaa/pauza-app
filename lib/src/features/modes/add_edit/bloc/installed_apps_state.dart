part of 'installed_apps_bloc.dart';

final class InstalledAppsState extends Equatable {
  const InstalledAppsState({
    this.isLoading = false,
    this.items = const <AppInfo>[],
    this.error,
  });

  final bool isLoading;
  final List<AppInfo> items;
  final Object? error;

  bool get hasError => error != null;

  InstalledAppsState loading() =>
      copyWith(isLoading: true);

  InstalledAppsState setError(Object error) =>
      copyWith(error: error, isLoading: false);

  InstalledAppsState copyWith({
    bool? isLoading,
    List<AppInfo>? items,
    Object? error,
  }) {
    return InstalledAppsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, items, error];
}
