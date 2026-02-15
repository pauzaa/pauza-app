import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/widget/stats_content.dart';
import 'package:pauza/src/features/stats/widget/stats_ios_usage_report_card.dart';
import 'package:pauza/src/features/stats/widget/stats_total_time_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  testWidgets('tabs switch and blocking tab shows placeholder', (tester) async {
    final bloc = StatsBloc(
      usageRepository: _WidgetStatsUsageRepository(),
      now: () => DateTime(2026, 2, 15, 9),
    )..add(const StatsStarted());
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(StatsTotalTimeCard), findsOneWidget);

    await tester.tap(find.text('Blocking Stats'));
    await tester.pump();

    expect(find.byType(StatsTotalTimeCard), findsNothing);
  });

  testWidgets('android usage tab renders chart cards', (tester) async {
    final bloc = StatsBloc(
      usageRepository: _WidgetStatsUsageRepository(),
      now: () => DateTime(2026, 2, 15, 9),
    )..add(const StatsStarted());
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(StatsTotalTimeCard), findsOneWidget);
  });

  testWidgets('ios usage tab renders ios report card', (tester) async {
    final bloc = StatsBloc(
      usageRepository: _WidgetStatsUsageRepository(),
      platform: PauzaPlatform.ios,
      now: () => DateTime(2026, 2, 15, 9),
    )..add(const StatsStarted());
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(StatsIosUsageReportCard), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.bloc});

  final StatsBloc bloc;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: PauzaTheme.dark,
      home: BlocProvider<StatsBloc>.value(
        value: bloc,
        child: const StatsContent(),
      ),
    );
  }
}

class _WidgetStatsUsageRepository implements StatsUsageRepository {
  @override
  Future<List<UsageStats>> getUsageStats({
    required DateTime start,
    required DateTime end,
  }) async {
    return <UsageStats>[
      UsageStats(
        appInfo: const AndroidAppInfo(
          packageId: AppIdentifier.android('social.app'),
          name: 'social.app',
          category: 'Social',
        ),
        totalDuration: const Duration(minutes: 120),
        totalLaunchCount: 1,
        bucketStart: start,
        bucketEnd: end,
        lastTimeUsed: start,
      ),
    ];
  }
}
