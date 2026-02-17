import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfileActionCard extends StatelessWidget {
  const ProfileActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        side: BorderSide(color: context.colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PauzaSpacing.medium,
            vertical: PauzaSpacing.medium,
          ),
          child: Row(
            children: <Widget>[
              SizedBox.square(
                dimension: PauzaFormSizes.medium,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      PauzaCornerRadius.medium,
                    ),
                    color: context.colorScheme.primaryContainer,
                  ),
                  child: Icon(icon, color: context.colorScheme.primary),
                ),
              ),
              const SizedBox(width: PauzaSpacing.medium),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
