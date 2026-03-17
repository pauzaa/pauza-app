import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';

@immutable
final class UsageAnalysisRequestDto extends Equatable {
  const UsageAnalysisRequestDto({
    required this.period,
    required this.appUsage,
    this.totalScreenTimeMs,
    this.totalUnlocks,
  });

  /// `'daily'` or `'weekly'`.
  final String period;

  final IList<AiAppUsageItemDto> appUsage;
  final int? totalScreenTimeMs;
  final int? totalUnlocks;

  Map<String, Object?> toJson() => <String, Object?>{
    'period': period,
    'app_usage': appUsage.map((e) => e.toJson()).toList(growable: false),
    if (totalScreenTimeMs != null) 'total_screen_time_ms': totalScreenTimeMs,
    if (totalUnlocks != null) 'total_unlocks': totalUnlocks,
  };

  @override
  List<Object?> get props => <Object?>[period, appUsage, totalScreenTimeMs, totalUnlocks];

  @override
  String toString() => 'UsageAnalysisRequestDto($period, apps: ${appUsage.length})';
}
