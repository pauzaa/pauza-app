import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaAppLogo extends StatelessWidget {
  const PauzaAppLogo({this.appName, this.tagline, this.logoWidget, super.key});

  final String? appName;
  final String? tagline;
  final Widget? logoWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: PauzaSpacing.large,
      children: <Widget>[
        _LogoMark(logoWidget: logoWidget),
        Column(
          spacing: PauzaSpacing.regular,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (appName case final appName? when appName.isNotEmpty)
              Text(
                appName,
                style: context.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
            if (tagline case final tagline? when tagline.isNotEmpty)
              Text(
                tagline,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  letterSpacing: 4.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ],
    );
  }
}

final class _LogoMark extends StatelessWidget {
  const _LogoMark({this.logoWidget});

  final Widget? logoWidget;

  @override
  Widget build(BuildContext context) {
    return logoWidget ?? const _FallbackLogoMark();
  }
}

final class _FallbackLogoMark extends StatelessWidget {
  const _FallbackLogoMark();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.colorScheme.primary, borderRadius: BorderRadius.circular(28)),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _PauseBar(color: context.colorScheme.onPrimary),
            const SizedBox(width: PauzaSpacing.small),
            _PauseBar(color: context.colorScheme.onPrimary),
          ],
        ),
      ),
    );
  }
}

final class _PauseBar extends StatelessWidget {
  const _PauseBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      child: const SizedBox(width: 18, height: 48),
    );
  }
}
