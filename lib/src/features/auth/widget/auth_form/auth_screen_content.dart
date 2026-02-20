import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/pauza_app.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/auth/widget/auth_form/auth_credentials_form.dart';
import 'package:pauza/src/features/auth/widget/auth_form/auth_header_section.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

typedef LocaleSelectionHandler =
    Future<void> Function(BuildContext context, Locale locale);
typedef OtpNavigationHandler = void Function(BuildContext context);

class AuthScreenContent extends StatefulWidget {
  const AuthScreenContent({super.key});

  @override
  State<AuthScreenContent> createState() => _AuthScreenContentState();
}

class _AuthScreenContentState extends State<AuthScreenContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (previous, current) {
            return current is AuthFlowFailure || current is AuthOtpRequired;
          },
          listener: (context, state) {
            if (state case AuthFlowFailure(:final failure)) {
              final message = failure.localizeString(context.l10n);
              context.showToast(message);
              return;
            }

            if (state case AuthOtpRequired()) {
              _onOtpRouteRequested();
            }
          },
          builder: (context, state) {
            final isSubmitting = state is AuthSubmitting;

            return Stack(
              children: [
                ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    bottom: PauzaSpacing.large,
                    top: PauzaSpacing.xxLarge,
                    left: PauzaSpacing.large,
                    right: PauzaSpacing.large,
                  ),
                  children: <Widget>[
                    const AuthHeaderSection(),
                    const SizedBox(height: PauzaSpacing.giant),
                    AuthCredentialsForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      onPasswordSubmitted: (_) => _submit(),
                      onLoginTap: _submit,
                      onForgotPasswordTap: _onForgotPasswordTap,
                      isSubmitting: isSubmitting,
                    ),
                  ],
                ),
                Positioned(
                  top: PauzaSpacing.large,
                  right: PauzaSpacing.large,
                  child: Builder(
                    builder: (context) {
                      return PauzaLanguageSelector(
                        currentLocale: context.watchFuseState.locale,
                        supportedLanguages: PauzaApp.supportedLanguages,
                        onLocaleSelected: _onLocaleSelected,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignInRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _onForgotPasswordTap() {
    // TODO: wire forgot password flow.
  }

  Future<void> _onLocaleSelected(Locale locale) async {
    try {
      context.changeAppLocale(locale);
    } on Object {
      // Ignore when AppFuse scope is not available in isolated widget tests.
    }
  }

  void _onOtpRouteRequested() {
    HelmRouter.push(context, PauzaRoutes.otp);
  }
}
