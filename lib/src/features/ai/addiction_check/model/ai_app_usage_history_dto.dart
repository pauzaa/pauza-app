import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';

@immutable
final class AiAppUsageHistoryDto extends Equatable {
  const AiAppUsageHistoryDto({
    required this.date,
    required this.apps,
  });

  /// Date in `YYYY-MM-DD` format.
  final String date;

  final IList<AiAppUsageItemDto> apps;

  Map<String, Object?> toJson() => <String, Object?>{
    'date': date,
    'apps': apps.map((e) => e.toJson()).toList(growable: false),
  };

  @override
  List<Object?> get props => <Object?>[date, apps];

  @override
  String toString() =>
      'AiAppUsageHistoryDto($date, apps: ${apps.length})';
}
