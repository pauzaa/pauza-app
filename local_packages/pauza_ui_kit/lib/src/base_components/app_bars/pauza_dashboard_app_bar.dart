import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaDashboardAppBar extends StatelessWidget {
  const PauzaDashboardAppBar({
    required this.greeting,
    required this.title,
    super.key,
    this.showSettingsButton = true,
    this.onSettingsPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: PauzaSpacing.large),
  });

  final String greeting;
  final String title;
  final bool showSettingsButton;
  final VoidCallback? onSettingsPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  greeting.toUpperCase(),
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.primary,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PauzaSpacing.small),
                Text(
                  title,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (showSettingsButton)
            Padding(
              padding: const EdgeInsets.only(top: PauzaSpacing.small),
              child: SizedBox(
                width: PauzaFormSizes.medium,
                height: PauzaFormSizes.medium,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: context.colorScheme.outlineVariant,
                    ),
                  ),
                  child: IconButton(
                    onPressed: onSettingsPressed,
                    icon: const Icon(Icons.settings),
                    color: context.colorScheme.onSurfaceVariant,
                    disabledColor: context.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
