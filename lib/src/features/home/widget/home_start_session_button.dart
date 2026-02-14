import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class HomeStartSessionButton extends StatelessWidget {
  const HomeStartSessionButton({required this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = l10n.startButton.toUpperCase();

    const buttonSize = 320.0;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: buttonSize + 30,
            height: buttonSize + 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colorScheme.primary, width: 2.5),
            ),
          ),
          Container(
            width: buttonSize + 60,
            height: buttonSize + 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colorScheme.primary, width: 2.5),
            ),
          ),
          Ink(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(shape: BoxShape.circle, color: context.colorScheme.primary),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colorScheme.surface,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.lock,
                      size: PauzaIconSizes.xxLarge,
                      color: context.colorScheme.primary.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(height: PauzaSpacing.large),
                Text(
                  title,
                  style: context.textTheme.headlineLarge?.copyWith(
                    letterSpacing: 4,
                    color: context.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PauzaSpacing.small),
                Text(
                  l10n.homePauzaSessionLabel.toUpperCase(),
                  style: context.textTheme.labelLarge?.copyWith(
                    letterSpacing: 4,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
