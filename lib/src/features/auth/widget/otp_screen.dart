import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/auth/widget/otp_code/otp_screen_content.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = RootScope.of(context).authBloc;

    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const OtpScreenContent(),
    );
  }
}
