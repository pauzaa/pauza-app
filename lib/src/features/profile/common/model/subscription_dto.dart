import 'package:flutter/foundation.dart';

@immutable
final class SubscriptionDto {
  const SubscriptionDto({
    required this.entitlement,
    required this.isActive,
    this.currentPeriodEnd,
  });

  factory SubscriptionDto.fromJson(Map<String, Object?> json) {
    DateTime? periodEnd;
    final rawEnd = json['current_period_end'];
    if (rawEnd is String && rawEnd.isNotEmpty) {
      periodEnd = DateTime.tryParse(rawEnd)?.toUtc();
    }

    return SubscriptionDto(
      entitlement: json['entitlement'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      currentPeriodEnd: periodEnd,
    );
  }

  final String entitlement;
  final bool isActive;
  final DateTime? currentPeriodEnd;

  Map<String, Object?> toJson() => <String, Object?>{
    'entitlement': entitlement,
    'is_active': isActive,
    'current_period_end': currentPeriodEnd?.toIso8601String(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionDto &&
        other.entitlement == entitlement &&
        other.isActive == isActive &&
        other.currentPeriodEnd == currentPeriodEnd;
  }

  @override
  int get hashCode => Object.hash(entitlement, isActive, currentPeriodEnd);

  @override
  String toString() =>
      'SubscriptionDto(entitlement: $entitlement, isActive: $isActive, '
      'currentPeriodEnd: $currentPeriodEnd)';
}
