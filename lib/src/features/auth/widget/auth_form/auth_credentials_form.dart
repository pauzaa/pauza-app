import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/validation.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class AuthCredentialsForm extends StatelessWidget {
  const AuthCredentialsForm({
    required this.formKey,
    required this.emailController,
    required this.onSubmitted,
    required this.onSendCodeTap,
    required this.isSubmitting,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSendCodeTap;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Form(
      key: formKey,
      child: Column(
        spacing: PauzaSpacing.xLarge,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PauzaTextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: onSubmitted,
            validator: (value) => PauzaValidators.validateEmail(value, l10n),
            enabled: !isSubmitting,
            decoration: PauzaInputDecoration(
              labelText: l10n.authEmailAddress.toUpperCase(),
              hintText: l10n.authEmailHint,
              labelStyle: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          PauzaFilledButton(
            width: double.infinity,
            disabled: isSubmitting,
            onPressed: onSendCodeTap,
            textStyle: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            title: Text(l10n.authSendCode.toUpperCase()),
            radius: PauzaCornerRadius.large,
          ),
        ],
      ),
    );
  }
}
