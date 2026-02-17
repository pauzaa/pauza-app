import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/auth/widget/auth_screen_content.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = RootScope.of(context).authBloc;

    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const AuthScreenContent(),
    );
  }
}
