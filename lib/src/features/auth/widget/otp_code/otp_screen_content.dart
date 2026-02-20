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
      final remaining = (_initialCountdownSeconds - elapsedSeconds).clamp(
        0,
        _initialCountdownSeconds,
      );

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
        context.read<AuthBloc>().add(const AuthFlowResetRequested());
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          return current is AuthFlowFailure;
        },
        listener: (context, state) {
          if (state case AuthFlowFailure(:final failure)) {
            context.showToast(failure.localizeString(context.l10n));
            return;
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: PauzaSpacing.large,
              ).copyWith(top: PauzaSpacing.xxLarge),
              children: <Widget>[
                BlocSelector<AuthBloc, AuthState, String>(
                  selector: (state) {
                    switch (state) {
                      case AuthIdle():
                        return '';
                      case AuthSubmitting():
                        return state.email ?? '';
                      case AuthOtpRequired():
                        return state.email;
                      case AuthFlowSuccess():
                        return state.email;
                      case AuthFlowFailure():
                        return state.email ?? '';
                    }
                  },
                  builder: (context, email) {
                    return OtpHeaderText(email: email);
                  },
                ),
                const SizedBox(height: PauzaSpacing.giant),
                BlocSelector<AuthBloc, AuthState, bool>(
                  selector: (state) {
                    return state is AuthSubmitting;
                  },
                  builder: (context, isSubmitting) {
                    return PauzaPinCodeField(
                      key: const Key('otp_pin_code_field'),
                      controller: _otpController,
                      enabled: !isSubmitting,
                      length: _otpLength,
                      onFilled: _submitCode,
                    );
                  },
                ),
                const SizedBox(height: PauzaSpacing.giant),
                OtpActionsSection(
                  countdownStream: _countdownStream.stream,
                  initialRemainingSeconds: _initialCountdownSeconds,
                  onResendTap: _onResendTap,
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
    if (authState is AuthSubmitting) {
      return;
    }

    context.read<AuthBloc>().add(
      AuthOtpSubmitted(otp: _otpController.text.trim()),
    );
  }

  void _onResendTap() {
    _startCountdown();
    // TODO: implement resend code API call
  }
}
