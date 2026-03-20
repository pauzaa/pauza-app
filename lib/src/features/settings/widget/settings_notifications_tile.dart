import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/settings/bloc/user_preferences_bloc.dart';
import 'package:pauza/src/features/settings/widget/settings_option_tile.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class SettingsNotificationsTile extends StatelessWidget {
  const SettingsNotificationsTile({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<UserPreferencesBloc>().state;
    final isEnabled = state.pushEnabled ?? true;

    return SettingsOptionTile(
      icon: Icons.notifications_rounded,
      title: title,
      trailing: PauzaSwitch(
        value: isEnabled,
        onChanged: (value) {
          context.read<UserPreferencesBloc>().add(UserPreferencesPushToggled(enabled: value));
        },
      ),
      onTap: () {
        context.read<UserPreferencesBloc>().add(UserPreferencesPushToggled(enabled: !isEnabled));
      },
    );
  }
}
