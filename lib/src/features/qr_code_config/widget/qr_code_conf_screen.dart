import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/qr_code_config/bloc/qr_code_conf_bloc.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_code_conf_content.dart';

class QrCodeConfScreen extends StatelessWidget {
  const QrCodeConfScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.qrCodeConfig);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          QrCodeConfBloc(linkedCodesRepository: RootScope.of(context).qrLinkedCodesRepository)
            ..add(const QrCodeLoadCodesRequested()),
      child: const QrCodeConfContent(),
    );
  }
}
