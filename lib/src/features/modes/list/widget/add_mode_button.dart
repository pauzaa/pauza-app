import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class AddModeButton extends StatelessWidget {
  const AddModeButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PauzaSpacing.medium,
        vertical: PauzaSpacing.medium,
      ),
      child: CustomPaint(
        painter: _DashedRoundedBorderPainter(
          color: colorScheme.primary.withValues(alpha: 0.5),
          strokeWidth: 1.4,
          radius: PauzaCornerRadius.large,
          dashWidth: 8,
          dashGap: 6,
        ),
        child: Material(
          color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: PauzaSpacing.large),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: PauzaSpacing.small,
                children: <Widget>[
                  Icon(Icons.add_circle_outline, color: colorScheme.primary),
                  Text(
                    l10n.addModeButton,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}
