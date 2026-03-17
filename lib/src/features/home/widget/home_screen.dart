import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/ai/daily_report/bloc/ai_daily_report_bloc.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/bloc/home_stats_bloc.dart';
import 'package:pauza/src/features/home/widget/home_content.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final rootScope = RootScope.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ModesListBloc(modesRepository: rootScope.modesRepository)..add(const ModesListRequested()),
        ),
        BlocProvider(
          create: (context) => BlockingBloc(
            blockingRepository: rootScope.blockingRepository,
            modesRepository: rootScope.modesRepository,
            nfcLinkedChipsRepository: rootScope.nfcLinkedChipsRepository,
            qrLinkedCodesRepository: rootScope.qrLinkedCodesRepository,
          )..add(const BlockingSyncRequested()),
        ),
        BlocProvider(
          create: (context) => HomeStatsBloc(
            streaksRepository: rootScope.streaksRepository,
            lifecycleActions: rootScope.blockingRepository.lifecycleActions,
          )..add(const HomeStatsLoadRequested()),
        ),
        BlocProvider(
          create: (context) => AiDailyReportBloc(
            aiRepository: rootScope.aiRepository,
            usageRepository: rootScope.statsUsageRepository,
            streaksRepository: rootScope.streaksRepository,
          ),
        ),
      ],
      child: const HomeContent(),
    );
  }
}
