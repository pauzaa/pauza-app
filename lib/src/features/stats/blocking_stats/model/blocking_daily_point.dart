import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/core/common/model/local_day_key.dart';

@immutable
final class BlockingDailyPoint extends Equatable {
  const BlockingDailyPoint({required this.localDay, required this.effectiveDuration});

  final LocalDayKey localDay;
  final Duration effectiveDuration;

  @override
  List<Object?> get props => <Object?>[localDay, effectiveDuration];
}
