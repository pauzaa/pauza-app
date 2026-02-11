import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/common/root_scope.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/widget/circular_mode_button.dart';
import 'package:pauza/src/features/home/widget/current_mode_display.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza/src/features/modes/list/widget/mode_picker_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final rootScope = RootScope.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ModesListBloc(modesRepository: rootScope.modesRepository)
                ..add(const ModesListRequested()),
        ),
        BlocProvider(
          create: (context) =>
              BlockingBloc(blockingRepository: rootScope.blockingRepository)
                ..add(const BlockingSyncRequested()),
        ),
      ],
      child: const HomeContent(),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BlockingBloc, BlockingState>(
      listener: (context, blockingState) {
        if (!blockingState.isBlocking) return;
        final activeModeId = blockingState.activeModeId;
        if (activeModeId == null) return;
        context.read<ModesListBloc>().add(ModesSelectionRequested(modeId: activeModeId));
      },

      builder: (context, blockingState) {
        return BlocSelector<ModesListBloc, ModesListState, Mode?>(
          selector: (state) => state.selectedMode,
          builder: (context, selectedMode) {
            final displayModeName = selectedMode?.title ?? 'No mode selected';

            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 32,
                  children: [
                    CircularModeButton(
                      isActive: blockingState.isBlocking,
                      isLoading: blockingState.isLoading,
                      onTap: () {
                        if (blockingState.isBlocking) {
                          context.read<BlockingBloc>().add(const BlockingStopRequested());
                          return;
                        }

                        if (selectedMode == null) {
                          ModePickerSheet.show(
                            context,
                            modes: context.read<ModesListBloc>().state.items,
                          );
                          return;
                        }

                        context.read<BlockingBloc>().add(BlockingStartRequested(selectedMode));
                      },
                    ),
                    CurrentModeDisplay(
                      modeName: displayModeName,
                      onTap: () async {
                        final selectedMode = await ModePickerSheet.show(
                          context,
                          modes: context.read<ModesListBloc>().state.items,
                        );
                        if (selectedMode == null) return;
                        if (context.mounted) {
                          context.read<ModesListBloc>().add(
                            ModesSelectionRequested(modeId: selectedMode.id),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
