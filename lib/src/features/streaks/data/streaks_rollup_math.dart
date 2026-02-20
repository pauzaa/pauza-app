import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

@immutable
final class StreakLifecycleEventPoint {
  const StreakLifecycleEventPoint({required this.action, required this.occurredAtUtc});

  final RestrictionLifecycleAction action;
  final DateTime occurredAtUtc;
}

@immutable
final class UtcInterval {
  const UtcInterval({required this.startUtc, required this.endUtc});

  final DateTime startUtc;
  final DateTime endUtc;

  static IList<UtcInterval> buildEffectiveIntervals({
    required IList<StreakLifecycleEventPoint> events,
    required DateTime? endedAtUtc,
    required DateTime refreshNowUtc,
  }) {
    var intervals = const IList<UtcInterval>.empty();
    DateTime? activeStartUtc;
    var isPaused = false;

    for (final event in events) {
      switch (event.action) {
        case RestrictionLifecycleAction.start:
          if (activeStartUtc == null && !isPaused) {
            activeStartUtc = event.occurredAtUtc;
          }
          break;
        case RestrictionLifecycleAction.pause:
          if (activeStartUtc != null && !isPaused) {
            intervals = _appendInterval(intervals: intervals, startUtc: activeStartUtc, endUtc: event.occurredAtUtc);
            activeStartUtc = null;
            isPaused = true;
          }
          break;
        case RestrictionLifecycleAction.resume:
          if (isPaused) {
            activeStartUtc = event.occurredAtUtc;
            isPaused = false;
          }
          break;
        case RestrictionLifecycleAction.end:
          if (activeStartUtc != null && !isPaused) {
            intervals = _appendInterval(intervals: intervals, startUtc: activeStartUtc, endUtc: event.occurredAtUtc);
          }
          activeStartUtc = null;
          isPaused = false;
          break;
      }
    }

    if (activeStartUtc != null && !isPaused) {
      final cap = endedAtUtc ?? refreshNowUtc;
      intervals = _appendInterval(intervals: intervals, startUtc: activeStartUtc, endUtc: cap);
    }

    return intervals;
  }

  static IList<UtcInterval> _appendInterval({
    required IList<UtcInterval> intervals,
    required DateTime startUtc,
    required DateTime endUtc,
  }) {
    if (!endUtc.isAfter(startUtc)) {
      return intervals;
    }

    return intervals.add(UtcInterval(startUtc: startUtc, endUtc: endUtc));
  }
}
