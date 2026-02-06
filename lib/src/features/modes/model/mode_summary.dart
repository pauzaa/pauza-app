import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/modes/model/mode.dart';

@immutable
class ModeSummary {
  const ModeSummary({required this.mode, required this.blockedAppsCount});

  final Mode mode;
  final int blockedAppsCount;

  @override
  String toString() =>
      'ModeSummary(mode: $mode, blockedAppsCount: $blockedAppsCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModeSummary &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          blockedAppsCount == other.blockedAppsCount;

  @override
  int get hashCode => Object.hash(mode, blockedAppsCount);
}
