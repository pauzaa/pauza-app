import 'package:flutter/material.dart';
import 'package:pauza/src/features/stats/blocking_stats/data/stats_blocking_repository.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';

final class FakeStatsBlockingRepository implements StatsBlockingRepository {
  FakeStatsBlockingRepository({required this.responses});

  final List<Object> responses;
  int calls = 0;
  DateTimeRange? lastWindow;
  DateTime? lastNowLocal;

  @override
  Future<BlockingStatsSnapshot> getBlockingSnapshot({required DateTimeRange window, required DateTime nowLocal}) async {
    lastWindow = window;
    lastNowLocal = nowLocal;

    final response = responses[calls++];
    if (response is BlockingStatsSnapshot) {
      return response;
    }
    throw response;
  }
}
