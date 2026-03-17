import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_entry.dart';

/// Maps stats [AppUsageEntry] list to AI [AiAppUsageItemDto] list.
IList<AiAppUsageItemDto> mapAppUsageToAiDtos(IList<AppUsageEntry> entries) {
  return entries.map(_mapEntry).toIList();
}

AiAppUsageItemDto _mapEntry(AppUsageEntry entry) {
  return AiAppUsageItemDto(
    appIdentifier: entry.appInfo.packageId.value,
    appName: entry.appInfo.name,
    totalTimeMs: entry.totalDuration.inMilliseconds,
    launchCount: entry.launchCount,
    category: entry.appInfo.category,
  );
}
