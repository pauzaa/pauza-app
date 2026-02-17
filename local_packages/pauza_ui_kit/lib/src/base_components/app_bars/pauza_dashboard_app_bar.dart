import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaDashboardAppBar extends StatelessWidget {
  const PauzaDashboardAppBar({
    required this.title,
    this.padding = EdgeInsets.zero,
    this.greeting,
    this.trailing,

    super.key,
  });

  final String? greeting;
  final String title;
  final Widget? trailing;
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
              spacing: PauzaSpacing.small,
              children: <Widget>[
                Text(
                  greeting?.toUpperCase() ?? '',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.primary,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  title,
                  style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (trailing case final trailing?)
            Padding(
              padding: const EdgeInsets.only(top: PauzaSpacing.small),
              child: trailing,
            ),
        ],
      ),
    );
  }
}
