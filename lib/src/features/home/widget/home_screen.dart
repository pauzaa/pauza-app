import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza/src/features/modes/list/widget/mode_picker_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.home);
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load modes and sync blocking state on init
    context.read<ModesListBloc>().add(ModesListRequested(platform: PauzaPlatform.current));
    context.read<BlockingBloc>().add(const BlockingSyncRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocBuilder<BlockingBloc, BlockingState>(
          builder: (context, blockingState) {
            return BlocBuilder<ModesListBloc, ModesListState>(
              builder: (context, modesState) {
                // Find current active mode
                final activeModeId = blockingState.activeModeId;
                final activeMode = activeModeId != null
                    ? modesState.items
                          .where((summary) => summary.mode.id == activeModeId)
                          .firstOrNull
                    : null;

                final isLoading = blockingState.isLoading || modesState.isLoading;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Circular button
                      _CircularModeButton(
                        isActive: blockingState.isBlocking,
                        isLoading: isLoading,
                        onTap: () => _onButtonTap(context, blockingState),
                      ),
                      const SizedBox(height: 32),

                      // Mode name display
                      _ModeNameDisplay(
                        modeName: activeMode?.mode.title ?? 'No mode selected',
                        isActive: blockingState.isBlocking,
                        onTap: () => _onModeNameTap(context),
                      ),

                      // Show error if present
                      if (blockingState.hasError || modesState.hasError) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Error: ${blockingState.error ?? modesState.error}',
                            style: TextStyle(color: Colors.red[700], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _onButtonTap(BuildContext context, BlockingState blockingState) {
    if (blockingState.isBlocking) {
      // Stop blocking
      context.read<BlockingBloc>().add(const BlockingStopRequested());
    } else {
      // Show mode picker to select a mode to start
      _onModeNameTap(context);
    }
  }

  void _onModeNameTap(BuildContext context) {
    ModePickerSheet.show(context);
  }
}

class _CircularModeButton extends StatelessWidget {
  const _CircularModeButton({required this.isActive, required this.isLoading, required this.onTap});

  final bool isActive;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.green[400] : Colors.grey[300],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Icon(isActive ? Icons.pause : Icons.play_arrow, size: 80, color: Colors.white),
      ),
    );
  }
}

class _ModeNameDisplay extends StatelessWidget {
  const _ModeNameDisplay({required this.modeName, required this.isActive, required this.onTap});

  final String modeName;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              modeName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.green[700] : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: isActive ? Colors.green[700] : Colors.grey[700]),
          ],
        ),
      ),
    );
  }
}
