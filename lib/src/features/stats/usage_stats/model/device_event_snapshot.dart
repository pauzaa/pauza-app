import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

/// Aggregated device-level event statistics for a queried time window.
///
/// Provides high-level KPIs (screen-on count, unlock count) derived from
/// [DeviceEventStats], plus the raw entries for flexible charting.
///
/// Requires Android 9+ (API 28+).
@immutable
final class DeviceEventSnapshot extends Equatable {
  const DeviceEventSnapshot({
    required this.screenOnCount,
    required this.totalScreenOnTime,
    required this.unlockCount,
    required this.eventEntries,
  });

  /// Number of times the screen became interactive.
  final int screenOnCount;

  /// Total duration the screen was in an interactive state.
  final Duration totalScreenOnTime;

  /// Number of times the device was unlocked (keyguard hidden).
  final int unlockCount;

  /// All device event stat entries returned by the plugin, for flexible
  /// charting beyond the pre-computed KPIs.
  final IList<DeviceEventStats> eventEntries;

  @override
  List<Object?> get props => <Object?>[screenOnCount, totalScreenOnTime, unlockCount, eventEntries];

  @override
  String toString() =>
      'DeviceEventSnapshot('
      'screenOn: $screenOnCount, '
      'screenOnTime: $totalScreenOnTime, '
      'unlocks: $unlockCount, '
      'entries: ${eventEntries.length})';
}
