import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows a Cupertino-style time picker modal.
///
/// Returns the selected [TimeOfDay] when the user taps the done button,
/// or `null` if the modal is dismissed without confirming.
Future<TimeOfDay?> showCupertinoTimePicker(
  BuildContext context, {
  required String? doneButtonLabel,
  TimeOfDay? initialTime,
}) async {
  final resolved = initialTime ?? const TimeOfDay(hour: 9, minute: 0);

  final initialDateTime = DateTime.now().copyWith(
    hour: resolved.hour,
    minute: resolved.minute,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );

  final pickedDateTime = await showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (BuildContext modalContext) {
      var current = initialDateTime;
      return SizedBox(
        height: 250,
        child: ColoredBox(
          color: CupertinoColors.systemBackground.resolveFrom(modalContext),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  onPressed: () => Navigator.of(modalContext).pop(current),
                  child: Text(doneButtonLabel ?? 'Done'),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialDateTime,
                  onDateTimeChanged: (DateTime value) => current = value,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (pickedDateTime == null) {
    return null;
  }
  return TimeOfDay.fromDateTime(pickedDateTime);
}
