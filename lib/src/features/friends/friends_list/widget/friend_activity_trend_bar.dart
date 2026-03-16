import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pauza/src/features/friends/common/model/daily_trend_dto.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class FriendActivityTrendBar extends StatelessWidget {
  const FriendActivityTrendBar({required this.trends, super.key});

  final List<DailyTrendDto> trends;

  @override
  Widget build(BuildContext context) {
    final colors = context.pauzaColorScheme;
    final maxMs = trends.fold<int>(0, (prev, t) => math.max(prev, t.effectiveMs));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final trend = index < trends.length ? trends[index] : null;
        final fraction = (maxMs > 0 && trend != null) ? trend.effectiveMs / maxMs : 0.0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Container(
              height: 24 * fraction + 4,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.3 + 0.7 * fraction),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      }),
    );
  }
}
