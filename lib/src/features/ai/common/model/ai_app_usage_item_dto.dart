import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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

  Map<String, Object?> toJson() => <String, Object?>{
    'app_identifier': appIdentifier,
    'app_name': appName,
    'total_time_ms': totalTimeMs,
    'launch_count': launchCount,
    if (category != null) 'category': category,
  };

  @override
  List<Object?> get props => <Object?>[
    appIdentifier,
    appName,
    totalTimeMs,
    launchCount,
    category,
  ];

  @override
  String toString() =>
      'AiAppUsageItemDto($appName, '
      'time: ${totalTimeMs}ms, '
      'launches: $launchCount)';
}
