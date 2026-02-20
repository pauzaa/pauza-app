import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/validation.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class AuthCredentialsForm extends StatelessWidget {
  const AuthCredentialsForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onPasswordSubmitted,
    required this.onLoginTap,
    required this.onForgotPasswordTap,
    required this.isSubmitting,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final ValueChanged<String> onPasswordSubmitted;
  final VoidCallback onLoginTap;
  final VoidCallback onForgotPasswordTap;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PauzaTextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
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
          const SizedBox(height: PauzaSpacing.large),
          PauzaTextFormField.password(
            controller: passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: onPasswordSubmitted,
            validator: (value) => PauzaValidators.validatePassword(value, l10n),
            enabled: !isSubmitting,
            decoration: PauzaInputDecoration(
              label: Row(
                children: <Widget>[
                  Expanded(child: Text(l10n.authPassword.toUpperCase())),
                  TextButton(
                    onPressed: onForgotPasswordTap,
                    child: Text(
                      l10n.authForgotPassword,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              labelStyle: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
              ),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              hintText: '••••••••',
            ),
          ),
          const SizedBox(height: PauzaSpacing.xLarge),
          PauzaFilledButton(
            width: double.infinity,
            disabled: isSubmitting,
            onPressed: onLoginTap,
            textStyle: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            title: Text(l10n.authLogIn.toUpperCase()),
            radius: PauzaCornerRadius.large,
          ),
        ],
      ),
    );
  }
}
