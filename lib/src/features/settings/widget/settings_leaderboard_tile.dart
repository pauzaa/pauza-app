import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/settings/bloc/user_preferences_bloc.dart';
import 'package:pauza/src/features/settings/widget/settings_option_tile.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class SettingsLeaderboardTile extends StatelessWidget {
  const SettingsLeaderboardTile({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<UserPreferencesBloc>().state;
    final isVisible = state.leaderboardVisible ?? true;

    return SettingsOptionTile(
      icon: Icons.leaderboard_rounded,
      title: title,
      trailing: PauzaSwitch(
        value: isVisible,
        onChanged: (value) {
          context.read<UserPreferencesBloc>().add(UserPreferencesLeaderboardToggled(visible: value));
        },
      ),
      onTap: () {
        context.read<UserPreferencesBloc>().add(UserPreferencesLeaderboardToggled(visible: !isVisible));
      },
    );
  }
}
