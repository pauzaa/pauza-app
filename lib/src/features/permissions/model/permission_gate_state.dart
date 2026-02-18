import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/permissions/model/pauza_permission_requirement.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart' show PermissionStatus;

@immutable
class PermissionGateState {
  PermissionGateState({Map<PauzaPermissionRequirement, PermissionStatus> statuses = const {}, DateTime? checkedAt, this.lastError})
    : statuses = Map<PauzaPermissionRequirement, PermissionStatus>.unmodifiable(statuses),
      checkedAt = checkedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  factory PermissionGateState.initial() => PermissionGateState();

  final Map<PauzaPermissionRequirement, PermissionStatus> statuses;
  final DateTime checkedAt;
  final Object? lastError;

  bool get isReady => firstMissing == null;

  PauzaPermissionRequirement? get firstMissing {
    for (final requirement in PauzaPermissionRequirement.requiredForCurrentPlatform) {
      final status = statusOf(requirement);
      if (!status.isGranted) {
        return requirement;
      }
    }
    return null;
  }

  PermissionStatus statusOf(PauzaPermissionRequirement requirement) => statuses[requirement] ?? PermissionStatus.notDetermined;

  PermissionGateState copyWith({Map<PauzaPermissionRequirement, PermissionStatus>? statuses, DateTime? checkedAt, Object? error}) {
    return PermissionGateState(statuses: statuses ?? this.statuses, checkedAt: checkedAt ?? this.checkedAt, lastError: error);
  }

  @override
  String toString() {
    final statusesView = statuses.entries.map((entry) => '${entry.key.id}:${entry.value.name}').join(', ');
    return 'PermissionGateState('
        'isReady: $isReady, '
        'firstMissing: ${firstMissing?.id}, '
        'checkedAt: $checkedAt, '
        'lastError: ${_errorSignature(lastError)}, '
        'statuses: {$statusesView}'
        ')';
  }

  static String? _errorSignature(Object? error) => error == null ? null : '${error.runtimeType}:${error.toString()}';

  static const MapEquality<PauzaPermissionRequirement, PermissionStatus> _statusesEquality =
      MapEquality<PauzaPermissionRequirement, PermissionStatus>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PermissionGateState &&
        _statusesEquality.equals(other.statuses, statuses) &&
        other.checkedAt == checkedAt &&
        _errorSignature(other.lastError) == _errorSignature(lastError);
  }

  @override
  int get hashCode => Object.hash(_statusesEquality.hash(statuses), checkedAt, _errorSignature(lastError));
}
