import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorSectionLabel extends StatelessWidget {
  const ModeEditorSectionLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelLarge?.copyWith(color: context.colorScheme.primary, letterSpacing: 2, fontWeight: FontWeight.w700),
      ),
    );
  }
}
