import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({required this.child, super.key, this.padding = PauzaSpacing.large});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}
