import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_entry.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('AiAppUsageItemDto.fromUsageEntries', () {
    test('limits app usage payloads to 500 items and caps per-app duration', () {
      final entries = List<AppUsageEntry>.generate(
        maxAiAppUsageItems + 1,
        (index) => AppUsageEntry(
          appInfo: AndroidAppInfo(
            packageId: AppIdentifier.android('com.example.app$index'),
            name: 'App $index',
            category: 'Productivity',
          ),
          totalDuration: Duration(milliseconds: maxAiDailyUsageMs + index + 1),
          launchCount: index,
          shareOfTotal: 0,
        ),
      ).toIList();

      final dtos = AiAppUsageItemDto.fromUsageEntries(entries, maxTotalTimeMs: maxAiDailyUsageMs);

      expect(dtos, hasLength(maxAiAppUsageItems));
      expect(dtos.first.totalTimeMs, maxAiDailyUsageMs);
      expect(dtos.last.appIdentifier, 'com.example.app499');
      expect(dtos.last.totalTimeMs, maxAiDailyUsageMs);
    });
  });
}
