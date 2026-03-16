import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:pauza/src/features/leaderboard/widget/leaderboard_body.dart';
import 'package:pauza/src/features/leaderboard/widget/leaderboard_tab_toggle.dart';

class LeaderboardContent extends StatelessWidget {
  const LeaderboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboardTitle),
        centerTitle: true,
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          return Column(
            children: <Widget>[
              LeaderboardTabToggle(selected: state.tab),
              Expanded(child: LeaderboardBody(state: state)),
            ],
          );
        },
      ),
    );
  }
}
