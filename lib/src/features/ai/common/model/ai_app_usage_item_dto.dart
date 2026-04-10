import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_entry.dart';

@immutable
final class AiAppUsageItemDto extends Equatable {
  const AiAppUsageItemDto({
    required this.appIdentifier,
    required this.appName,
    required this.totalTimeMs,
    required this.launchCount,
    this.category,
  });

  final String appIdentifier;
  final String appName;
  final int totalTimeMs;
  final int launchCount;
  final String? category;

  static IList<AiAppUsageItemDto> fromUsageEntries(IList<AppUsageEntry> entries) {
    return entries
        .map(
          (e) => AiAppUsageItemDto(
            appIdentifier: e.appInfo.packageId.value,
            appName: e.appInfo.name,
            totalTimeMs: e.totalDuration.inMilliseconds,
            launchCount: e.launchCount,
            category: e.appInfo.category,
          ),
        )
        .toIList();
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'app_identifier': appIdentifier,
    'app_name': appName,
    'total_time_ms': totalTimeMs,
    'launch_count': launchCount,
    if (category != null) 'category': category,
  };

  @override
  List<Object?> get props => <Object?>[appIdentifier, appName, totalTimeMs, launchCount, category];

  @override
  String toString() =>
      'AiAppUsageItemDto($appName, '
      'time: ${totalTimeMs}ms, '
      'launches: $launchCount)';
}
