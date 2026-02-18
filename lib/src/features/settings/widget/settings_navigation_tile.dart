import 'package:flutter/material.dart';
import 'package:pauza/src/features/settings/widget/settings_option_tile.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class SettingsNavigationTile extends StatelessWidget {
  const SettingsNavigationTile({required this.icon, required this.title, required this.onTap, super.key});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SettingsOptionTile(
      icon: icon,
      title: title,
      trailing: Icon(Icons.chevron_right_rounded, color: context.colorScheme.primary),
      onTap: onTap,
    );
  }
}
