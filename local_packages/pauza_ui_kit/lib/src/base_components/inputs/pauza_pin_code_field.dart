import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PauzaPinCodeField extends StatefulWidget {
  const PauzaPinCodeField({
    required this.controller,
    required this.length,
    this.enabled = true,
    this.onFilled,
    this.onChanged,
    super.key,
  }) : assert(length > 0);

  final TextEditingController controller;
  final bool enabled;
  final int length;
  final VoidCallback? onFilled;
  final ValueChanged<String>? onChanged;

  @override
  State<PauzaPinCodeField> createState() => _PauzaPinCodeFieldState();
}

class _PauzaPinCodeFieldState extends State<PauzaPinCodeField> {
  final FocusNode _internalFocus = FocusNode();

  TextEditingController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _internalFocus.requestFocus();
    _controller.addListener(_onValueChanged);
  }

  @override
  void didUpdateWidget(covariant PauzaPinCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_onValueChanged);
      widget.controller.addListener(_onValueChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    _internalFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: AbsorbPointer(
              child: TextField(
                enabled: widget.enabled,
                focusNode: _internalFocus,
                controller: _controller,
                cursorColor: Colors.transparent,
                style: const TextStyle(fontSize: 12, height: 1, color: Colors.transparent),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enableInteractiveSelection: false,
                showCursor: false,
                minLines: 1,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                maxLength: widget.length,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(widget.length),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                if (!widget.enabled) {
                  return;
                }
                if (context.findRenderObject() case final RenderBox box) {
                  final boxWidth = box.constraints.maxWidth / widget.length;
                  final index = (details.localPosition.dx / boxWidth).floor();
                  final offset = index.clamp(0, _controller.text.length);
                  _controller.selection = TextSelection.fromPosition(TextPosition(offset: offset));
                }
                if (_internalFocus.hasFocus) {
                  _internalFocus.unfocus();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _internalFocus.requestFocus();
                  });
                } else {
                  _internalFocus.requestFocus();
                }
              },
              child: _PinCodeSquares(
                controller: _controller,
                focusNode: _internalFocus,
                length: widget.length,
                enabled: widget.enabled,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onValueChanged() {
    widget.onChanged?.call(_controller.text);
    if (_controller.text.length == widget.length) {
      widget.onFilled?.call();
    }
  }
}

class _PinCodeSquares extends StatefulWidget {
  const _PinCodeSquares({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final bool enabled;

  @override
  State<_PinCodeSquares> createState() => _PinCodeSquaresState();
}

class _PinCodeSquaresState extends State<_PinCodeSquares> {
  late Listenable _mergedListenable;

  @override
  void initState() {
    super.initState();
    _mergedListenable = Listenable.merge(<Listenable>[widget.controller, widget.focusNode]);
  }

  @override
  void didUpdateWidget(covariant _PinCodeSquares oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller) || !identical(oldWidget.focusNode, widget.focusNode)) {
      _mergedListenable = Listenable.merge(<Listenable>[widget.controller, widget.focusNode]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListenableBuilder(
          listenable: _mergedListenable,
          builder: (context, child) {
            final focusedOffset = widget.controller.selection.baseOffset;
            final maxSize = math.min(constraints.maxHeight, constraints.maxWidth / (widget.length + 1));

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.length, (index) {
                final hasFocus = widget.focusNode.hasFocus && focusedOffset == index;
                final isFilled = widget.controller.text.length > index;
                final symbol = isFilled ? widget.controller.text[index] : null;

                return _PinCodeSquare(
                  key: Key('pauza_pin_code_cell_$index'),
                  maxSize: maxSize,
                  hasFocus: hasFocus,
                  isFilled: isFilled,
                  enabled: widget.enabled,
                  symbol: symbol,
                );
              }),
            );
          },
        );
      },
    );
  }
}

class _PinCodeSquare extends StatelessWidget {
  const _PinCodeSquare({
    required this.maxSize,
    required this.hasFocus,
    required this.isFilled,
    required this.enabled,
    required this.symbol,
    super.key,
  });

  final double maxSize;
  final bool hasFocus;
  final bool isFilled;
  final bool enabled;
  final String? symbol;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final borderColor = !enabled
        ? colorScheme.outlineVariant.withValues(alpha: 0.5)
        : hasFocus || isFilled
        ? colorScheme.primary
        : colorScheme.outline;

    final textColor = enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant;
    final backgroundColor = enabled ? colorScheme.surfaceContainerLow : colorScheme.surfaceContainer;

    return SizedBox.square(
      dimension: hasFocus || isFilled ? maxSize : maxSize / 1.08,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(PauzaCornerRadius.small),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: switch ((hasFocus, symbol)) {
            (true, _) => VerticalDivider(color: textColor, thickness: 2, endIndent: 14, indent: 14),
            (_, final String value) => Text(
              value,
              style: context.textTheme.displaySmall?.copyWith(color: textColor, fontWeight: FontWeight.w700),
            ),
            _ => DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const SizedBox.square(dimension: 6),
            ),
          },
        ),
      ),
    );
  }
}
