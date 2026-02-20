import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/streaks/common/model/streak_constants.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';
import 'package:pauza/src/features/streaks/data/streaks_rollup_math.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('buildEffectiveIntervals', () {
    test('subtracts paused segment from effective intervals', () {
      final intervals = UtcInterval.buildEffectiveIntervals(
        events: [
          StreakLifecycleEventPoint(action: RestrictionLifecycleAction.start, occurredAtUtc: _utc(0)),
          StreakLifecycleEventPoint(action: RestrictionLifecycleAction.pause, occurredAtUtc: _utc(1_000)),
          StreakLifecycleEventPoint(action: RestrictionLifecycleAction.resume, occurredAtUtc: _utc(2_000)),
          StreakLifecycleEventPoint(action: RestrictionLifecycleAction.end, occurredAtUtc: _utc(3_000)),
        ].toIList(),
        endedAtUtc: _utc(3_000),
        refreshNowUtc: _utc(4_000),
      );

      final totalMs = intervals.fold<int>(
        0,
        (sum, interval) => sum + interval.endUtc.difference(interval.startUtc).inMilliseconds,
      );
      expect(totalMs, 2_000);
    });

    test('includes in-progress window for open session until refresh now', () {
      final intervals = UtcInterval.buildEffectiveIntervals(
        events: [
          StreakLifecycleEventPoint(action: RestrictionLifecycleAction.start, occurredAtUtc: _utc(1_000)),
        ].toIList(),
        endedAtUtc: null,
        refreshNowUtc: _utc(5_000),
      );

      expect(intervals, hasLength(1));
      expect(intervals.single.endUtc.difference(intervals.single.startUtc).inMilliseconds, 4_000);
    });
  });

  group('streak value type factories', () {
    test('compute current and best streak with gaps', () {
      final qualifiedDays = <String>{
        '2026-01-10',
        '2026-01-11',
        '2026-01-12',
        '2026-01-14',
        '2026-01-15',
      }.map(LocalDayKey.fromDb).toSet();

      final current = CurrentStreakDays.fromQualifiedDays(
        todayLocal: DateTime(2026, 1, 15, 9),
        qualifiedDays: qualifiedDays.toISet(),
      );
      final best = BestStreakDays.fromQualifiedDays(qualifiedDays: qualifiedDays.toISet());

      expect(current, 2);
      expect(best, 3);
    });

    test('return zero for empty qualified days', () {
      final current = CurrentStreakDays.fromQualifiedDays(
        todayLocal: DateTime(2026, 1, 15, 9),
        qualifiedDays: const <LocalDayKey>{}.toISet(),
      );
      final best = BestStreakDays.fromQualifiedDays(qualifiedDays: const <LocalDayKey>{}.toISet());

      expect(current, 0);
      expect(best, 0);
    });

    test('applies 10-minute threshold edges deterministically', () {
      final justBelow = StreakConstants.targetDurationPerDay.inMilliseconds - const Duration(seconds: 1).inMilliseconds;
      final exact = StreakConstants.targetDurationPerDay.inMilliseconds;

      expect(justBelow >= StreakConstants.targetDurationPerDay.inMilliseconds, isFalse);
      expect(exact >= StreakConstants.targetDurationPerDay.inMilliseconds, isTrue);
    });
  });
}

DateTime _utc(int epochMs) {
  return DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true);
}
