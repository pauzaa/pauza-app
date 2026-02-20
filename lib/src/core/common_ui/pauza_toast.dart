import 'package:flutter/material.dart';

class Toast extends SnackBar {
  factory Toast({
    required String message,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    Color? textColor,
    TextStyle? textStyle,
    double width = 300,
    Key? key,
  }) {
    final effectiveTextStyle = (textStyle ?? TextStyle(color: textColor ?? Colors.white, fontSize: 16)).copyWith(
      color: textColor,
    );
    return Toast._(
      duration: duration,
      width: width,
      content: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(color: backgroundColor ?? Colors.black, borderRadius: BorderRadius.circular(100)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(message, textAlign: TextAlign.center, style: effectiveTextStyle),
          ),
        ),
      ),
      key: key,
    );
  }

  const Toast._({required super.content, required super.duration, required super.width, super.key})
    : super(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.none,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
      );
}

extension ShowToast on BuildContext {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showToast(
    String message, {
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    Color? textColor,
    TextStyle? textStyle,
    double width = 300,
  }) {
    ScaffoldMessenger.maybeOf(this)?.clearSnackBars();
    return ScaffoldMessenger.maybeOf(this)?.showSnackBar(
      Toast(
        message: message,
        duration: duration,
        backgroundColor: backgroundColor ?? ColorScheme.of(this).tertiary,
        textColor: textColor ?? ColorScheme.of(this).onTertiary,
        textStyle: textStyle,
        width: width,
      ),
    );
  }
}
