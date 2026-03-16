import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PaywallProductCard extends StatelessWidget {
  const PaywallProductCard({required this.package, required this.isSelected, required this.onTap, super.key});

  final Package package;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final borderColor = isSelected ? context.colorScheme.primary : context.colorScheme.outline;

    return Material(
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(PauzaSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(product.title, style: context.textTheme.titleLarge),
              const SizedBox(height: PauzaSpacing.small),
              Text(product.priceString, style: context.textTheme.headlineSmall),
              if (product.description.isNotEmpty) ...[
                const SizedBox(height: PauzaSpacing.small),
                Text(
                  product.description,
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
