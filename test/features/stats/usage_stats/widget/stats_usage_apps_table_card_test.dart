import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_apps_table_card.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('renders localized headers', (tester) async {
    await _pumpCard(
      tester,
      usageStats: <UsageStats>[
        _usage(name: 'Alpha', minutes: 20, launches: 2, lastTimeUsed: DateTime(2026, 2, 10, 8)),
      ].lock,
    );

    expect(find.text('APP USAGE'), findsOneWidget);
    expect(find.text('App'), findsOneWidget);
    expect(find.text('Usage'), findsOneWidget);
    expect(find.text('Launches'), findsOneWidget);
    expect(find.text('Last used'), findsOneWidget);
  });

  testWidgets('displays rows in given order', (tester) async {
    await _pumpCard(
      tester,
      usageStats: <UsageStats>[
        _usage(name: 'Top App', minutes: 120, launches: 2, lastTimeUsed: DateTime(2026, 2, 10, 8)),
        _usage(name: 'Mid App', minutes: 60, launches: 2, lastTimeUsed: DateTime(2026, 2, 10, 8)),
        _usage(name: 'Low App', minutes: 30, launches: 2, lastTimeUsed: DateTime(2026, 2, 10, 8)),
      ].lock,
    );

    final topY = tester.getTopLeft(find.text('Top App')).dy;
    final midY = tester.getTopLeft(find.text('Mid App')).dy;
    final lowY = tester.getTopLeft(find.text('Low App')).dy;

    expect(topY, lessThan(midY));
    expect(midY, lessThan(lowY));
  });

  testWidgets('shows fallback for null last used', (tester) async {
    await _pumpCard(
      tester,
      usageStats: <UsageStats>[_usage(name: 'No Last Used', minutes: 15, launches: 1, lastTimeUsed: null)].lock,
    );

    expect(find.text('-'), findsOneWidget);
  });
}

Future<void> _pumpCard(WidgetTester tester, {required IList<UsageStats> usageStats}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: PauzaTheme.dark,
      home: Scaffold(
        body: SingleChildScrollView(child: StatsUsageAppsTableCard(usageStats: usageStats)),
      ),
    ),
  );
  await tester.pump();
}

UsageStats _usage({
  required String name,
  required int minutes,
  required int launches,
  required DateTime? lastTimeUsed,
}) {
  return UsageStats(
    appInfo: AndroidAppInfo(
      packageId: AppIdentifier.android(name.toLowerCase().replaceAll(' ', '.')),
      name: name,
      category: 'Other',
    ),
    totalDuration: Duration(minutes: minutes),
    totalLaunchCount: launches,
    bucketStart: DateTime(2026, 2, 10),
    bucketEnd: DateTime(2026, 2, 10, 23, 59, 59),
    lastTimeUsed: lastTimeUsed,
  );
}
