import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PauzaNavigationDestination {
  const PauzaNavigationDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class PauzaBottomNavigationBar extends StatelessWidget {
  const PauzaBottomNavigationBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onTabPressed,
    super.key,
  });

  final int selectedIndex;
  final void Function(int) onTabPressed;
  final List<PauzaNavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: PauzaSpacing.medium),
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
                  border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.7)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(PauzaSpacing.small),
                  child: Row(
                    spacing: 4,
                    children: List<Widget>.generate(destinations.length, (index) {
                      final destination = destinations[index];
                      final isSelected = selectedIndex == index;

                      return InkWell(
                        onTap: () => onTabPressed(index),
                        child: Semantics(
                          selected: isSelected,
                          label: destination.label,
                          button: true,
                          child: AnimatedContainer(
                            width: PauzaFormSizes.small,
                            height: PauzaFormSizes.small,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? context.colorScheme.primary : Colors.transparent,
                            ),
                            child: Icon(
                              destination.icon,
                              size: 28,
                              color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
