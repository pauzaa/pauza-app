import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/widget/home_active_session.dart';
import 'package:pauza/src/features/home/widget/home_default_widget.dart';
import 'package:pauza/src/features/home/widget/home_pause_session.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<BlockingBloc, BlockingState>(
      listenWhen: (previous, current) {
        return previous.error != current.error && current.hasError;
      },
      listener: (context, state) {
        if (state.error case final Localizable error) {
          final message = error.localize(l10n);
          context.showToast(message);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: PauzaSpacing.large, horizontal: PauzaSpacing.large),
            children: <Widget>[
              PauzaDashboardAppBar(
                greeting: l10n.homeGreeting(DateTime.now().hour.toString()),
                title: l10n.homeDashboardTitle,
              ),

              Padding(
                padding: const EdgeInsets.only(top: PauzaSpacing.xLarge),
                child: BlocBuilder<BlockingBloc, BlockingState>(
                  builder: (context, blockingState) {
                    if (blockingState.isPaused) {
                      return const HomePauseSession();
                    } else if (blockingState.isBlocking) {
                      return const HomeActiveSession();
                    }

                    return const HomeDefaultWidget();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
