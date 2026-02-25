import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_usage_insights.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_tab_content.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import '../helpers/fake_stats_usage_repository.dart';
import '../helpers/pump_stats_widget.dart';

void main() {
  testWidgets('renders expanded android stats content', (tester) async {
    final repo = FakeStatsUsageRepository(
      current: <UsageStats>[
        UsageStats(
          appInfo: const AndroidAppInfo(
            packageId: AppIdentifier.android('social.app'),
            name: 'social.app',
            category: 'Social',
          ),
          totalDuration: const Duration(minutes: 120),
          totalLaunchCount: 10,
          bucketStart: DateTime(2026, 2, 10),
          bucketEnd: DateTime(2026, 2, 16),
          lastTimeUsed: DateTime(2026, 2, 10),
        ),
      ],
      deviceInsights: const DeviceUsageInsights(
        unlockCount: 11,
        lockCount: 11,
        pickupCount: 16,
        screenOnDuration: Duration(minutes: 180),
        unlockedDuration: Duration(minutes: 150),
        screenOnSessionAverage: Duration(minutes: 12),
        unlocksPerDayAverage: 2.2,
        firstUnlockAt: null,
        lastUnlockAt: null,
        source: DeviceUsageInsightsSource.eventStats,
      ),
    );

    final bloc = StatsBloc(usageRepository: repo, platform: PauzaPlatform.android)..add(const StatsStarted());
    addTearDown(bloc.close);

    await pumpStatsWidget(
      tester,
      BlocProvider<StatsBloc>.value(value: bloc, child: const StatsUsageTabContent()),
      scrollable: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(StatsUsageTabContent), findsOneWidget);
    expect(find.text('TOTAL TIME'), findsOneWidget);
    expect(find.text('USAGE TREND'), findsOneWidget);
    expect(find.text('DEVICE INSIGHTS'), findsOneWidget);
    expect(find.text('HOURLY HEATMAP'), findsOneWidget);
    expect(find.text('TOP ENGAGEMENT APPS'), findsOneWidget);
    expect(find.text('APP USAGE'), findsOneWidget);
  });

  testWidgets('app usage table renders one row for duplicate app identities', (tester) async {
    final repo = FakeStatsUsageRepository(
      current: <UsageStats>[
        UsageStats(
          appInfo: const AndroidAppInfo(
            packageId: AppIdentifier.android('dup.app'),
            name: 'dup.app',
            category: 'Social',
          ),
          totalDuration: const Duration(minutes: 50),
          totalLaunchCount: 2,
          bucketStart: DateTime(2026, 2, 10),
          bucketEnd: DateTime(2026, 2, 16),
          lastTimeUsed: DateTime(2026, 2, 10),
        ),
        UsageStats(
          appInfo: const AndroidAppInfo(
            packageId: AppIdentifier.android('dup.app'),
            name: 'dup.app',
            category: 'Social',
          ),
          totalDuration: const Duration(minutes: 70),
          totalLaunchCount: 5,
          bucketStart: DateTime(2026, 2, 10),
          bucketEnd: DateTime(2026, 2, 16),
          lastTimeUsed: DateTime(2026, 2, 11),
        ),
      ],
    );

    final bloc = StatsBloc(usageRepository: repo, platform: PauzaPlatform.android)..add(const StatsStarted());
    addTearDown(bloc.close);

    await pumpStatsWidget(
      tester,
      BlocProvider<StatsBloc>.value(value: bloc, child: const StatsUsageTabContent()),
      scrollable: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('dup.app'), findsOneWidget);
  });
}
