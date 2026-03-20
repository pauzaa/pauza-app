import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class OnboardingSlidePage extends StatelessWidget {
  const OnboardingSlidePage({required this.icon, required this.title, required this.body, super.key});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
            child: SizedBox(width: 120, height: 120, child: Icon(icon, size: 56, color: colorScheme.primary)),
          ),
          const SizedBox(height: 40),
          Text(title, style: context.textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            body,
            style: context.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
