import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';

@immutable
final class BlockingDailyPoint extends Equatable {
  const BlockingDailyPoint({required this.localDay, required this.effectiveDuration});

  final LocalDayKey localDay;
  final Duration effectiveDuration;

  @override
  List<Object?> get props => <Object?>[localDay, effectiveDuration];
}
