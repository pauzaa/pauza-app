import 'package:flutter/material.dart';
import 'package:pauza/src/core/connectivity/widget/internet_required_body.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/localization/l10n.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: InternetRequiredBody(
        gate: PauzaDependencies.of(context).internetHealthGate,
        offlineTitle: l10n.leaderboardOfflineTitle,
        offlineMessage: l10n.leaderboardOfflineMessage,
        offlineRetryButtonLabel: l10n.leaderboardRetryButton,
        child: const Center(child: Text('Leaderboard')),
      ),
    );
  }
}
