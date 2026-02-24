import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsSectionHeader extends StatelessWidget {
  const StatsSectionHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: context.textTheme.headlineSmall?.copyWith(color: context.colorScheme.onSurfaceVariant, letterSpacing: 2),
    );
  }
}
