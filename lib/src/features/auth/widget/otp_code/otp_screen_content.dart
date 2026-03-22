import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/auth/widget/otp_code/otp_actions_section.dart';
import 'package:pauza/src/features/auth/widget/otp_code/otp_header_text.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class OtpScreenContent extends StatefulWidget {
  const OtpScreenContent({super.key});

  @override
  State<OtpScreenContent> createState() => _OtpScreenContentState();
}

class _OtpScreenContentState extends State<OtpScreenContent> {
  static const int _otpLength = 6;
  static const int _initialCountdownSeconds = 60;

  late final TextEditingController _otpController;
  late final StreamController<int> _countdownStream;
  Stopwatch? _stopwatch;
  Timer? _emitTimer;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _countdownStream = StreamController<int>();
    _startCountdown();
  }

  @override
  void dispose() {
    _emitTimer?.cancel();
    _countdownStream.close();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _emitTimer?.cancel();
    _stopwatch = Stopwatch()..start();

    _countdownStream.add(_initialCountdownSeconds);

    _emitTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final elapsedSeconds = _stopwatch!.elapsed.inSeconds;
      final remaining = (_initialCountdownSeconds - elapsedSeconds).clamp(0, _initialCountdownSeconds);

      _countdownStream.add(remaining);

      if (remaining <= 0) {
        _stopwatch!.stop();
        _emitTimer?.cancel();
        _emitTimer = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          if (current is AuthIdle && previous is AuthResetting) return true;
          if (current is AuthFlowFailure) return true;
          if (current case AuthOtpRequired(:final resent) when resent) {
            final previousResent = switch (previous) {
              AuthOtpRequired(:final resentCount) => resentCount,
              _ => 0,
            };
            return current.resentCount > previousResent;
          }
          return false;
        },
        listener: (context, state) {
          if (state is AuthIdle) {
            Navigator.of(context).pop();
            return;
          }

          if (state case AuthOtpRequired(:final resent) when resent) {
            _otpController.clear();
            _startCountdown();
            return;
          }

          if (state case AuthFlowFailure(:final error)) {
            _otpController.clear();
            final message = switch (error) {
              final Localizable localizable => localizable.localize(context.l10n),
              _ => context.l10n.authFailureUnknown,
            };
            context.showToast(message);
            return;
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.large).copyWith(top: PauzaSpacing.xxLarge),
              children: <Widget>[
                BlocSelector<AuthBloc, AuthState, String>(
                  selector: (state) => state.email ?? '',
                  builder: (context, email) {
                    return OtpHeaderText(email: email);
                  },
                ),
                const SizedBox(height: PauzaSpacing.giant),
                BlocSelector<AuthBloc, AuthState, bool>(
                  selector: (state) => state.isBusy,
                  builder: (context, isBusy) {
                    return PauzaPinCodeField(
                      key: const Key('otp_pin_code_field'),
                      controller: _otpController,
                      enabled: !isBusy,
                      length: _otpLength,
                      onFilled: _submitCode,
                    );
                  },
                ),
                const SizedBox(height: PauzaSpacing.giant),
                BlocSelector<AuthBloc, AuthState, bool>(
                  selector: (state) => state.isBusy,
                  builder: (context, isBusy) {
                    return OtpActionsSection(
                      countdownStream: _countdownStream.stream,
                      initialRemainingSeconds: _initialCountdownSeconds,
                      isBusy: isBusy,
                      onResendTap: _onResendTap,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitCode() {
    final authState = context.read<AuthBloc>().state;
    if (authState.isBusy) return;

    context.read<AuthBloc>().add(AuthOtpSubmitted(otp: _otpController.text.trim()));
  }

  void _onResendTap() {
    final authState = context.read<AuthBloc>().state;
    if (authState.isBusy) return;
    context.read<AuthBloc>().add(const AuthOtpResendRequested());
  }

  void _handleBackNavigation() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthResetting) return;

    context.read<AuthBloc>().add(const AuthFlowResetRequested());
  }
}
