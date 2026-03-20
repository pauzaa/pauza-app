import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({required this.count, required this.currentPage, super.key});

  final int count;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
