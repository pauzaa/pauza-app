import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaDateRangePickerCard extends StatelessWidget {
  const PauzaDateRangePickerCard({
    required this.selectedRange,
    required this.rangeTextBuilder,
    required this.onRangeChanged,
    required this.maxDate,
    this.minDate,
    super.key,
  });

  final DateTimeRange selectedRange;
  final String Function(DateTimeRange range) rangeTextBuilder;
  final ValueChanged<DateTimeRange> onRangeChanged;
  final DateTime? minDate;
  final DateTime maxDate;

  bool get _canShiftRight {
    final upperBound = maxDate.dayEnd;

    return selectedRange.end.isBefore(upperBound);
  }

  bool get _canShiftLeft {
    final lowerBound = minDate?.dayStart;
    if (lowerBound == null) {
      return true;
    }

    return selectedRange.start.isAfter(lowerBound);
  }

  DateTime get _pickerFirstDate {
    final lowerBound = minDate;
    if (lowerBound != null) {
      return lowerBound;
    }

    return DateTime.now().subtract(const Duration(days: 365));
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PauzaSpacing.medium),
        child: Row(
          spacing: PauzaSpacing.small,
          children: <Widget>[
            _ArrowButton(
              icon: Icons.chevron_left,
              onPressed: _canShiftLeft
                  ? () => onRangeChanged(selectedRange.shiftLeftCapped(minDate))
                  : null,
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    initialDateRange: selectedRange,
                    firstDate: _pickerFirstDate,
                    lastDate: maxDate,
                  );
                  if (picked != null) {
                    onRangeChanged(picked);
                  }
                },
                child: Text(
                  rangeTextBuilder(selectedRange),
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall,
                ),
              ),
            ),
            _ArrowButton(
              icon: Icons.chevron_right,
              onPressed: _canShiftRight
                  ? () => onRangeChanged(selectedRange.shiftRightCapped(maxDate))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

final class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: PauzaIconSizes.medium,
      color: context.colorScheme.primary,
      disabledColor: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
      icon: Icon(icon),
    );
  }
}

extension DateRangeX on DateTimeRange {
  int get inclusiveDays => end.difference(start).inDays + 1;

  DateTimeRange shiftByInclusiveRange(int direction) {
    final delta = Duration(days: inclusiveDays * direction);
    return DateTimeRange(start: start.add(delta).dayStart, end: end.add(delta).dayEnd);
  }

  DateTimeRange shiftRightCapped(DateTime maxDate) {
    final upperBound = maxDate.dayEnd;
    final shifted = shiftByInclusiveRange(1);
    if (!shifted.end.isAfter(upperBound)) {
      return shifted;
    }

    final overflowDays = shifted.end.difference(upperBound).inDays;
    return DateTimeRange(
      start: shifted.start.subtract(Duration(days: overflowDays)).dayStart,
      end: upperBound,
    );
  }

  DateTimeRange shiftLeftCapped(DateTime? minDate) {
    final lowerBound = minDate?.dayStart;
    final shifted = shiftByInclusiveRange(-1);
    if (lowerBound == null || !shifted.start.isBefore(lowerBound)) {
      return shifted;
    }

    final overflowDays = lowerBound.difference(shifted.start).inDays;
    return DateTimeRange(
      start: lowerBound,
      end: shifted.end.add(Duration(days: overflowDays)).dayEnd,
    );
  }
}

extension DateTimeX on DateTime {
  DateTime get dayStart => DateTime(year, month, day);

  DateTime get dayEnd => DateTime(year, month, day, 23, 59, 59, 999);
}
