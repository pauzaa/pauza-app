import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_engagement_insight.dart';
import 'package:pauza/src/features/stats/usage_stats/model/stats_section_status.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_top_engagement_apps_card.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import '../helpers/pump_stats_widget.dart';

void main() {
  testWidgets('renders engagement rows on success', (tester) async {
    final apps = <AppEngagementInsight>[
      const AppEngagementInsight(
        appInfo: AndroidAppInfo(packageId: AppIdentifier.android('app.one'), name: 'App One'),
        totalDuration: Duration(minutes: 80),
        totalLaunchCount: 20,
        averageSessionDuration: Duration(minutes: 4),
        launchesPerHour: 1.5,
        engagementScore: 0.82,
      ),
      const AppEngagementInsight(
        appInfo: AndroidAppInfo(packageId: AppIdentifier.android('app.two'), name: 'App Two'),
        totalDuration: Duration(minutes: 40),
        totalLaunchCount: 10,
        averageSessionDuration: Duration(minutes: 3),
        launchesPerHour: 0.8,
        engagementScore: 0.61,
      ),
    ].lock;

    await pumpStatsWidget(
      tester,
      StatsTopEngagementAppsCard(status: StatsSectionStatus.success, apps: apps, onRetry: () {}),
    );

    expect(find.text('TOP ENGAGEMENT APPS'), findsOneWidget);
    expect(find.text('App One'), findsOneWidget);
    expect(find.text('App Two'), findsOneWidget);
  });

  testWidgets('renders empty state message', (tester) async {
    await pumpStatsWidget(
      tester,
      StatsTopEngagementAppsCard(
        status: StatsSectionStatus.empty,
        apps: const IListConst<AppEngagementInsight>(<AppEngagementInsight>[]),
        onRetry: () {},
      ),
    );

    expect(find.text('No insight data for the selected period.'), findsOneWidget);
  });
}
