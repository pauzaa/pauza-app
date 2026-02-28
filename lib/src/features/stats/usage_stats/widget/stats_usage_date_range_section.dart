import 'package:flutter/material.dart';
import 'package:pauza/src/features/stats/common/widget/stats_date_range_picker_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsUsageDateRangeSection extends StatelessWidget {
  const StatsUsageDateRangeSection({
    required this.selectedRange,
    required this.maxDate,
    required this.isLoading,
    required this.onRangeChanged,
    super.key,
  });

  final DateTimeRange selectedRange;
  final DateTime maxDate;
  final bool isLoading;
  final ValueChanged<DateTimeRange> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatsDateRangePickerCard(selectedRange: selectedRange, maxDate: maxDate, onRangeChanged: onRangeChanged),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(top: PauzaSpacing.small),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PauzaCornerRadius.small),
              child: const LinearProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
