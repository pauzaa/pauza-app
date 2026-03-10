import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/modes/select_apps/bloc/installed_apps_bloc.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import '../../../../../helpers/helpers.dart';

const AppIdentifier _instagramId = AppIdentifier.android('com.instagram.android');
const AppIdentifier _xId = AppIdentifier.android('com.twitter.android');
const AppIdentifier _youtubeId = AppIdentifier.android('com.google.android.youtube');

const List<AndroidAppInfo> _apps = <AndroidAppInfo>[
  AndroidAppInfo(packageId: _instagramId, name: 'Instagram', category: 'Social'),
  AndroidAppInfo(packageId: _xId, name: 'X', category: 'Social'),
  AndroidAppInfo(packageId: _youtubeId, name: 'YouTube', category: 'Video'),
];

void main() {
  late MockInstalledAppsRepository repository;

  setUp(() {
    repository = MockInstalledAppsRepository();
  });

  group('InstalledAppsBloc', () {
    blocTest<InstalledAppsBloc, InstalledAppsState>(
      'load initializes apps and categories',
      setUp: () {
        when(
          () => repository.getAndroidInstalledApps(
            includeSystemApps: any(named: 'includeSystemApps'),
            includeIcons: any(named: 'includeIcons'),
          ),
        ).thenAnswer((_) async => _apps);
      },
      build: () => InstalledAppsBloc(installedAppsRepository: repository, debounceDuration: Duration.zero),
      act: (bloc) => bloc.add(const InstalledAppsRequested()),
      verify: (bloc) {
        expect(bloc.state.hasError, isFalse);
        expect(bloc.state.availableCategoryKeys, containsAll(<String>['Social', 'Video']));
        expect(bloc.state.visibleGroupedApps.keys, containsAll(<String>['Social', 'Video']));
      },
    );

    blocTest<InstalledAppsBloc, InstalledAppsState>(
      'search filters apps and resets missing selected category',
      setUp: () {
        when(
          () => repository.getAndroidInstalledApps(
            includeSystemApps: any(named: 'includeSystemApps'),
            includeIcons: any(named: 'includeIcons'),
          ),
        ).thenAnswer((_) async => _apps);
      },
      build: () => InstalledAppsBloc(installedAppsRepository: repository, debounceDuration: Duration.zero),
      act: (bloc) async {
        bloc.add(const InstalledAppsRequested());
        await Future<void>.delayed(Duration.zero);

        bloc.add(const CategoryFilterChanged(categoryKey: 'Video'));
        await Future<void>.delayed(Duration.zero);

        bloc.add(const SearchQueryChanged(searchQuery: 'insta'));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.selectedCategoryKey, isNull);
        expect(bloc.state.visibleGroupedApps.keys, <String>['Social']);
      },
    );

    blocTest<InstalledAppsBloc, InstalledAppsState>(
      'category filter limits visible groups',
      setUp: () {
        when(
          () => repository.getAndroidInstalledApps(
            includeSystemApps: any(named: 'includeSystemApps'),
            includeIcons: any(named: 'includeIcons'),
          ),
        ).thenAnswer((_) async => _apps);
      },
      build: () => InstalledAppsBloc(installedAppsRepository: repository, debounceDuration: Duration.zero),
      act: (bloc) async {
        bloc.add(const InstalledAppsRequested());
        await Future<void>.delayed(Duration.zero);

        bloc.add(const CategoryFilterChanged(categoryKey: 'Social'));
      },
      verify: (bloc) {
        expect(bloc.state.visibleGroupedApps.keys, <String>['Social']);
        expect(bloc.state.visibleGroupedApps['Social']?.length, 2);
      },
    );

    blocTest<InstalledAppsBloc, InstalledAppsState>(
      'failure path sets error state',
      setUp: () {
        when(
          () => repository.getAndroidInstalledApps(
            includeSystemApps: any(named: 'includeSystemApps'),
            includeIcons: any(named: 'includeIcons'),
          ),
        ).thenThrow(Exception('failed'));
      },
      build: () => InstalledAppsBloc(installedAppsRepository: repository, debounceDuration: Duration.zero),
      act: (bloc) => bloc.add(const InstalledAppsRequested()),
      verify: (bloc) {
        expect(bloc.state.hasError, isTrue);
        expect(bloc.state.isLoading, isFalse);
      },
    );
  });
}
