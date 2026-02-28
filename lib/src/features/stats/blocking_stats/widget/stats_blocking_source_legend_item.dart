import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingSourceLegendItem extends StatelessWidget {
  const StatsBlockingSourceLegendItem({required this.color, required this.label, required this.value, super.key});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PauzaSpacing.tiny),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: PauzaSpacing.small),
          Flexible(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: PauzaSpacing.small),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
