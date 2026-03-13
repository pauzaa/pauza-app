import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/ai/addiction_check/model/ai_app_usage_history_dto.dart';
import 'package:pauza/src/features/ai/addiction_check/model/ai_daily_screen_time_dto.dart';
import 'package:pauza/src/features/ai/addiction_check/model/ai_first_unlock_time_dto.dart';

@immutable
final class AddictionCheckRequestDto extends Equatable {
  const AddictionCheckRequestDto({
    required this.appUsageHistory,
    required this.dailyScreenTimeHistory,
    this.firstUnlockTimes,
  });

  final IList<AiAppUsageHistoryDto> appUsageHistory;
  final IList<AiDailyScreenTimeDto> dailyScreenTimeHistory;
  final IList<AiFirstUnlockTimeDto>? firstUnlockTimes;

  Map<String, Object?> toJson() => <String, Object?>{
    'app_usage_history':
        appUsageHistory.map((e) => e.toJson()).toList(growable: false),
    'daily_screen_time_history':
        dailyScreenTimeHistory.map((e) => e.toJson()).toList(growable: false),
    if (firstUnlockTimes != null)
      'first_unlock_times':
          firstUnlockTimes!.map((e) => e.toJson()).toList(growable: false),
  };

  @override
  List<Object?> get props => <Object?>[
    appUsageHistory,
    dailyScreenTimeHistory,
    firstUnlockTimes,
  ];

  @override
  String toString() =>
      'AddictionCheckRequestDto('
      'history: ${appUsageHistory.length} days, '
      'screenTime: ${dailyScreenTimeHistory.length} days)';
}
