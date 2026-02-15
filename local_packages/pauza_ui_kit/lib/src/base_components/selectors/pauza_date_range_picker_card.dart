import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaDateRangePickerCard extends StatelessWidget {
  const PauzaDateRangePickerCard({
    required this.title,
    required this.selectedRange,
    required this.rangeTextBuilder,
    required this.onRangeChanged,
    required this.minDate,
    required this.maxDate,
    super.key,
  });

  final String title;
  final DateTimeRange selectedRange;
  final String Function(DateTimeRange range) rangeTextBuilder;
  final ValueChanged<DateTimeRange> onRangeChanged;
  final DateTime minDate;
  final DateTime maxDate;

  int get _rangeInclusiveDays =>
      selectedRange.end.difference(selectedRange.start).inDays + 1;

  bool get _canShiftRight {
    final shifted = _shift(1);
    return !shifted.end.isAfter(maxDate);
  }

  bool get _canShiftLeft {
    final shifted = _shift(-1);
    return !shifted.start.isBefore(minDate);
  }

  DateTimeRange _shift(int direction) {
    final delta = Duration(days: _rangeInclusiveDays * direction);
    return DateTimeRange(
      start: selectedRange.start.add(delta),
      end: selectedRange.end.add(delta),
    );
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
        padding: const EdgeInsets.symmetric(
          horizontal: PauzaSpacing.medium,
          vertical: PauzaSpacing.medium,
        ),
        child: Row(
          children: <Widget>[
            _ArrowButton(
              icon: Icons.chevron_left,
              onPressed: _canShiftLeft
                  ? () => onRangeChanged(_shift(-1))
                  : null,
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    initialDateRange: selectedRange,
                    firstDate: minDate,
                    lastDate: maxDate,
                  );
                  if (picked != null) {
                    onRangeChanged(picked);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: PauzaSpacing.small,
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        title,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: PauzaSpacing.small),
                      Text(
                        rangeTextBuilder(selectedRange),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _ArrowButton(
              icon: Icons.chevron_right,
              onPressed: _canShiftRight
                  ? () => onRangeChanged(_shift(1))
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
      disabledColor: context.colorScheme.onSurfaceVariant.withValues(
        alpha: 0.3,
      ),
      icon: Icon(icon),
    );
  }
}
