import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class CircularModeButton extends StatelessWidget {
  const CircularModeButton({
    required this.isActive,
    required this.isLoading,
    required this.onTap,
    super.key,
  });

  final bool isActive;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: SizedBox.square(
        dimension: 200,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            isActive ? Icons.pause : Icons.play_arrow,
            size: 80,
            color: context.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
