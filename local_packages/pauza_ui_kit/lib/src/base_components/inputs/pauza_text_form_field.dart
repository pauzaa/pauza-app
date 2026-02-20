import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pauza_ui_kit/src/base_components/buttons/pauza_icon_button.dart';
import 'package:pauza_ui_kit/src/base_components/inputs/pauza_input_decoration.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

typedef ObscureBuilder = Widget Function(BuildContext, bool, ValueSetter<bool>);

final class PauzaTextFormField extends StatefulWidget {
  const PauzaTextFormField({
    this.onChanged,
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration = const PauzaInputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.style,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.validator,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.extraWidget,
    this.allowInteractionOnDisabled = true,
  }) : assert(initialValue == null || controller == null);

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final PauzaInputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool readOnly;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTap;
  final AutovalidateMode autovalidateMode;
  final Widget? extraWidget;
  final bool allowInteractionOnDisabled;

  static Widget defaultObscureIconBuilder(BuildContext context, bool obscure, ValueSetter<bool> changeObscure) {
    return PauzaIconButton(
      onPressed: () => changeObscure(!obscure),
      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
    );
  }

  static Widget password({
    required bool obscureText,
    ValueChanged<String>? onChanged,
    ObscureBuilder obscureIconBuilder = defaultObscureIconBuilder,
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    FocusNode? focusNode,
    PauzaInputDecoration decoration = const PauzaInputDecoration(),
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool autofocus = false,
    bool readOnly = false,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onFieldSubmitted,
    VoidCallback? onEditingComplete,
    VoidCallback? onTap,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    Widget? extraWidget,
    bool allowInteractionOnDisabled = true,
  }) {
    return _PauzaPasswordField(
      key: key,
      builder: (BuildContext context, bool obscure, ValueSetter<bool> setObscure) {
        return PauzaTextFormField(
          onChanged: onChanged,
          controller: controller,
          initialValue: initialValue,
          focusNode: focusNode,
          decoration: decoration.copyWith(suffixIcon: obscureIconBuilder(context, obscure, setObscure)),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: style,
          textAlign: textAlign,
          textCapitalization: textCapitalization,
          autofocus: autofocus,
          readOnly: readOnly,
          obscureText: obscure,
          maxLines: maxLines,
          minLines: minLines,
          expands: expands,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          enabled: enabled,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          onEditingComplete: onEditingComplete,
          onTap: onTap,
          autovalidateMode: autovalidateMode,
          extraWidget: extraWidget,
          allowInteractionOnDisabled: allowInteractionOnDisabled,
        );
      },
      obscure: obscureText,
    );
  }

  @override
  State<PauzaTextFormField> createState() => _PauzaTextFormFieldState();
}

final class _PauzaTextFormFieldState extends State<PauzaTextFormField> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;

  TextEditingController get _controller => widget.controller ?? _internalController;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController(text: widget.initialValue ?? '');
    _internalFocusNode = FocusNode();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant PauzaTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      _focusNode.addListener(_handleFocusChanged);
    }
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _internalController.dispose();
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;
    final effectivePauzaDecoration = widget.decoration.applyDefaults(inputDecorationTheme);
    final effectiveDecoration = effectivePauzaDecoration.configureInputDecoration(
      context,
      hasFocus: _focusNode.hasFocus,
      isEnabled: widget.enabled,
      controller: _controller,
      onChanged: widget.onChanged,
    );

    final effectiveReadOnly = widget.allowInteractionOnDisabled && !widget.enabled ? true : widget.readOnly;

    Widget textField = TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: effectiveDecoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      style: widget.style ?? context.textTheme.bodyLarge,
      textAlign: widget.textAlign,
      textCapitalization: widget.textCapitalization,
      autofocus: widget.autofocus,
      readOnly: effectiveReadOnly,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled || widget.allowInteractionOnDisabled,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onEditingComplete: widget.onEditingComplete,
      onTap: widget.onTap,
      autovalidateMode: widget.autovalidateMode,
    );

    if (widget.extraWidget case final extraWidget?) {
      textField = Row(
        children: <Widget>[
          Expanded(child: textField),
          const SizedBox(width: PauzaSpacing.medium),
          extraWidget,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (effectivePauzaDecoration.labelText case final labelText? when labelText.isNotEmpty)
          Text(labelText, style: effectivePauzaDecoration.labelStyle ?? context.textTheme.labelLarge)
        else if (effectivePauzaDecoration.label case final label?)
          DefaultTextStyle.merge(
            style: effectivePauzaDecoration.labelStyle ?? context.textTheme.labelLarge,
            child: label,
          ),
        textField,
      ],
    );
  }
}

final class _PauzaPasswordField extends StatefulWidget {
  const _PauzaPasswordField({required this.builder, required this.obscure, super.key});

  final bool obscure;
  final Widget Function(BuildContext context, bool obscure, ValueSetter<bool> setObscure) builder;

  @override
  State<_PauzaPasswordField> createState() => _PauzaPasswordFieldState();
}

final class _PauzaPasswordFieldState extends State<_PauzaPasswordField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _obscure, (bool value) {
      setState(() {
        _obscure = value;
      });
    });
  }
}
