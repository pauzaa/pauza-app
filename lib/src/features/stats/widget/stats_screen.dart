import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/widget/stats_content.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.stats);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StatsBloc(usageRepository: RootScope.of(context).statsUsageRepository)
            ..add(const StatsStarted()),
      child: const StatsContent(),
    );
  }
}
