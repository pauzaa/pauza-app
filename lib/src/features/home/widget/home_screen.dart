import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
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
        BlocProvider(create: (context) => ModesListBloc(modesRepository: rootScope.modesRepository)..add(const ModesListRequested())),
        BlocProvider(
          create: (context) => BlockingBloc(blockingRepository: rootScope.blockingRepository)..add(const BlockingSyncRequested()),
        ),
      ],
      child: const HomeContent(),
    );
  }
}
