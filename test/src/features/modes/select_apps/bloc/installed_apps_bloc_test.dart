import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/modes/select_apps/bloc/installed_apps_bloc.dart';
import 'package:pauza/src/features/modes/select_apps/data/pauza_screen_time_installed_apps_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('InstalledAppsBloc', () {
    test('load initializes apps and categories', () async {
      final bloc = InstalledAppsBloc(
        installedAppsRepository: _FakeInstalledAppsRepository(apps: _apps),
        debounceDuration: Duration.zero,
      );

      bloc.add(const InstalledAppsRequested());

      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.hasError, isFalse);
      expect(bloc.state.availableCategoryKeys, containsAll(<String>['Social', 'Video']));
      expect(bloc.state.visibleGroupedApps.keys, containsAll(<String>['Social', 'Video']));

      await bloc.close();
    });

    test('search filters apps and resets missing selected category', () async {
      final bloc = InstalledAppsBloc(
        installedAppsRepository: _FakeInstalledAppsRepository(apps: _apps),
        debounceDuration: Duration.zero,
      );

      bloc.add(const InstalledAppsRequested());
      await Future<void>.delayed(Duration.zero);

      bloc.add(const CategoryFilterChanged(categoryKey: 'Video'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.selectedCategoryKey, 'Video');

      bloc.add(const SearchQueryChanged(searchQuery: 'insta'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.selectedCategoryKey, isNull);
      expect(bloc.state.visibleGroupedApps.keys, <String>['Social']);

      await bloc.close();
    });

    test('category filter limits visible groups', () async {
      final bloc = InstalledAppsBloc(
        installedAppsRepository: _FakeInstalledAppsRepository(apps: _apps),
        debounceDuration: Duration.zero,
      );

      bloc.add(const InstalledAppsRequested());
      await Future<void>.delayed(Duration.zero);

      bloc.add(const CategoryFilterChanged(categoryKey: 'Social'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.visibleGroupedApps.keys, <String>['Social']);
      expect(bloc.state.visibleGroupedApps['Social']?.length, 2);

      await bloc.close();
    });

    test('failure path sets error state', () async {
      final bloc = InstalledAppsBloc(
        installedAppsRepository: _FakeInstalledAppsRepository(error: Exception('failed')),
        debounceDuration: Duration.zero,
      );

      bloc.add(const InstalledAppsRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.hasError, isTrue);
      expect(bloc.state.isLoading, isFalse);

      await bloc.close();
    });
  });
}

const AppIdentifier _instagramId = AppIdentifier.android('com.instagram.android');
const AppIdentifier _xId = AppIdentifier.android('com.twitter.android');
const AppIdentifier _youtubeId = AppIdentifier.android('com.google.android.youtube');

const List<AndroidAppInfo> _apps = <AndroidAppInfo>[
  AndroidAppInfo(packageId: _instagramId, name: 'Instagram', category: 'Social'),
  AndroidAppInfo(packageId: _xId, name: 'X', category: 'Social'),
  AndroidAppInfo(packageId: _youtubeId, name: 'YouTube', category: 'Video'),
];

class _FakeInstalledAppsRepository implements InstalledAppsRepository {
  _FakeInstalledAppsRepository({this.apps = const <AndroidAppInfo>[], this.error});

  final List<AndroidAppInfo> apps;
  final Object? error;

  @override
  Future<List<AndroidAppInfo>> getAndroidInstalledApps({
    bool includeSystemApps = false,
    bool includeIcons = true,
  }) async {
    if (error case final currentError?) {
      throw currentError;
    }

    return apps;
  }

  @override
  Future<List<IOSAppInfo>> selectIOSApps({List<IOSAppInfo>? preSelectedApps}) async {
    return preSelectedApps ?? const <IOSAppInfo>[];
  }
}
