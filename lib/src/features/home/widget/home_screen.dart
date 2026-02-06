import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/blocking/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/modes/bloc/modes_bloc.dart';
import 'package:pauza/src/features/modes/widget/mode_picker_sheet.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<BlockingBloc, BlockingState>(
            builder: (context, blockingState) {
              if (blockingState.isBlocking) {
                return const _StopStateBody();
              }
              return const _IdleStateBody();
            },
          ),
        ),
      ),
    );
  }
}

class _StopStateBody extends StatelessWidget {
  const _StopStateBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SizedBox(
        width: double.infinity,
        child: PauzaFilledButton(
          onPressed: () {
            context.read<BlockingBloc>().add(const BlockingStopRequested());
          },
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(l10n.stopButton),
          ),
        ),
      ),
    );
  }
}

class _IdleStateBody extends StatelessWidget {
  const _IdleStateBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModesBloc, ModesState>(
      builder: (context, modesState) {
        final selected = modesState.selectedMode;
        final mode = selected?.mode;
        final blockedAppsCount = selected?.blockedAppsCount ?? 0;
        final canStart = mode != null && mode.isEnabled && blockedAppsCount > 0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PauzaFilledButton(
              disabled: !canStart,
              onPressed: canStart
                  ? () {
                      context.read<BlockingBloc>().add(
                        BlockingStartRequested(
                          modeId: mode.id,
                          platform: PauzaPlatform.current,
                        ),
                      );
                    }
                  : null,
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(AppLocalizations.of(context).startButton),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => ModePickerSheet.show(context),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ModeCardContent(
                    modeTitle: mode?.title,
                    blockedAppsCount: blockedAppsCount,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ModeCardContent extends StatelessWidget {
  const _ModeCardContent({
    required this.modeTitle,
    required this.blockedAppsCount,
  });

  final String? modeTitle;
  final int blockedAppsCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.selectModeTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          modeTitle ?? l10n.noModesEmptyState,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.blockedAppsCountLabel(blockedAppsCount),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
