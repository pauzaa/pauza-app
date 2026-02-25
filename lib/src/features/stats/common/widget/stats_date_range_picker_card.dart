import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsDateRangePickerCard extends StatelessWidget {
  const StatsDateRangePickerCard({
    required this.selectedRange,
    required this.maxDate,
    required this.onRangeChanged,
    this.minDate,
    super.key,
  });

  final DateTimeRange selectedRange;
  final DateTime maxDate;
  final DateTime? minDate;
  final ValueChanged<DateTimeRange> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    return PauzaDateRangePickerCard(
      selectedRange: selectedRange,
      minDate: minDate ?? DateTime(2020),
      maxDate: maxDate,
      rangeTextBuilder: _formatRange,
      onRangeChanged: onRangeChanged,
    );
  }

  String _formatRange(DateTimeRange range) {
    return '${DateFormat('MMM d').format(range.start)} - ${DateFormat('MMM d').format(range.end)}';
  }
}
