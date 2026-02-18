import 'package:flutter/material.dart';
import 'package:pauza/src/features/settings/widget/settings_option_tile.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class SettingsNotificationsTile extends StatefulWidget {
  const SettingsNotificationsTile({required this.title, super.key});

  final String title;

  @override
  State<SettingsNotificationsTile> createState() =>
      _SettingsNotificationsTileState();
}

final class _SettingsNotificationsTileState
    extends State<SettingsNotificationsTile> {
  bool _isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return SettingsOptionTile(
      icon: Icons.notifications_rounded,
      title: widget.title,
      trailing: PauzaSwitch(
        value: _isEnabled,
        onChanged: (value) {
          setState(() {
            _isEnabled = value;
          });
        },
      ),
      onTap: () {
        setState(() {
          _isEnabled = !_isEnabled;
        });
      },
    );
  }
}
