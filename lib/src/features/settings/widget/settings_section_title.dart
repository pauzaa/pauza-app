import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: context.textTheme.titleMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      ),
    );
  }
}
