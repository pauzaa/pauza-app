import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class AuthFailureMessage extends StatelessWidget {
  const AuthFailureMessage({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
        border: Border.all(color: context.colorScheme.error),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PauzaSpacing.medium),
        child: Text(
          message,
          style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.error, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
