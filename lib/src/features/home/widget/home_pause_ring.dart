import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

/// Stream-driven countdown ring with smooth animation between stream ticks.
/// - The ring animates smoothly from the previous value to the new one.
class HomePauseRing extends StatefulWidget {
  const HomePauseRing({
    required this.total,
    required this.startedAt,
    this.initialValue,
    super.key,
    this.size = 320,
    this.strokeWidth = 18,
    this.trackColor,
    this.progressColor,
    this.subText,
    this.cap = StrokeCap.round,
    this.gapDegrees = 14, // small gap like in your screenshot
    this.textStyle,
    this.subTextStyle,
  });

  final Duration total;
  final DateTime startedAt;
  final Duration? initialValue;
  final double size;
  final double strokeWidth;
  final String? subText;

  final Color? trackColor;
  final Color? progressColor;

  final StrokeCap cap;
  final double gapDegrees;

  final TextStyle? textStyle;
  final TextStyle? subTextStyle;

  @override
  State<HomePauseRing> createState() => _HomePauseRingState();
}

class _HomePauseRingState extends State<HomePauseRing> with SingleTickerProviderStateMixin {
  // value range [0..1]: 1 = full remaining, 0 = elapsed
  late final AnimationController _ac;
  late final Stream<Duration> _stream;
  late final StreamSubscription<Duration> _sub;

  Duration get effectiveInitialValue =>
      widget.initialValue ?? widget.total - DateTime.now().difference(widget.startedAt);

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
      vsync: this,
      value: _normalizeRemaining(effectiveInitialValue),
      duration: const Duration(milliseconds: 900),
    );
    _stream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => widget.total - DateTime.now().difference(widget.startedAt),
    ).asBroadcastStream();
    _sub = _stream.listen((remaining) => _ac.animateTo(_normalizeRemaining(remaining), curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _sub.cancel();
    _ac.dispose();
    super.dispose();
  }

  double _normalizeRemaining(Duration remaining) {
    final totalMs = widget.total.inMilliseconds;
    if (totalMs <= 0) return 0;
    final r = remaining.inMilliseconds.clamp(0, totalMs);
    return r / totalMs;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle =
        widget.textStyle ?? context.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.0);

    final effectiveSubTextStyle =
        widget.subTextStyle ??
        context.textTheme.titleLarge?.copyWith(
          color: context.colorScheme.primary,
          letterSpacing: 2.2,
          fontWeight: FontWeight.w700,
        );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ac,
        builder: (_, _) {
          return CustomPaint(
            painter: _RingPainter(
              trackColor: widget.trackColor ?? context.colorScheme.primary.withValues(alpha: 0.45),
              progressColor: widget.progressColor ?? context.colorScheme.primary,
              strokeWidth: widget.strokeWidth,
              cap: widget.cap,
              gapDegrees: widget.gapDegrees,
              progress: _ac.value,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: PauzaSpacing.small,
                children: [
                  StreamBuilder<Duration>(
                    stream: _stream,
                    initialData: widget.initialValue ?? effectiveInitialValue,
                    builder: (_, snap) =>
                        Text((snap.data ?? Duration.zero).formatTimerHhMmSs(), style: effectiveTextStyle),
                  ),
                  if (widget.subText case final subText?) Text(subText, style: effectiveSubTextStyle),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
    required this.cap,
    required this.gapDegrees,
    required this.progress, // normalized [0..1]
  });

  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;
  final StrokeCap cap;
  final double gapDegrees;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Leave a small gap in the ring (like the screenshot)
    final gap = gapDegrees * math.pi / 180.0;
    final fullSweep = (2 * math.pi) - gap;

    // Start at top (-90deg) and center the gap there
    // so the "break" is around 12 o'clock.
    final start = -math.pi / 2 + gap / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = cap
      ..color = trackColor;

    // Track
    canvas.drawArc(rect, start, fullSweep, false, trackPaint);

    final progSweep = fullSweep * progress.clamp(0.0, 1.0);

    if (progSweep > 0) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = cap
        ..color = progressColor;

      canvas.drawArc(rect, start, progSweep, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.progress != progress ||
        old.trackColor != trackColor ||
        old.progressColor != progressColor ||
        old.strokeWidth != strokeWidth ||
        old.cap != cap ||
        old.gapDegrees != gapDegrees;
  }
}
