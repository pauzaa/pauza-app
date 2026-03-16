import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/connectivity/widget/internet_required_body.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:pauza/src/features/leaderboard/widget/leaderboard_content.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (context) => LeaderboardBloc(
        leaderboardRepository: RootScope.of(context).leaderboardRepository,
      )..add(const LeaderboardLoadRequested()),
      child: InternetRequiredBody(
        gate: PauzaDependencies.of(context).internetHealthGate,
        offlineTitle: l10n.leaderboardOfflineTitle,
        offlineMessage: l10n.leaderboardOfflineMessage,
        offlineRetryButtonLabel: l10n.leaderboardRetryButton,
        child: const LeaderboardContent(),
      ),
    );
  }
}
