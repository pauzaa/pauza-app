import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/emergency_stop/widget/confirm_emergency_stop_dialog.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/model/blocking_action_proof.dart';
import 'package:pauza/src/features/home/widget/home_pause_pill.dart';
import 'package:pauza/src/features/home/widget/home_session_button.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/nfc/widget/nfc_chip_scan_sheet.dart';
import 'package:pauza/src/features/qr_code/widget/qr_code_scan_sheet.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class HomeActiveSession extends StatelessWidget {
  const HomeActiveSession({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      spacing: PauzaSpacing.medium,
      children: [
        Text(
          l10n.homeSessionDurationLabel.toUpperCase(),
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge?.copyWith(
            letterSpacing: 4,
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),

        BlocSelector<BlockingBloc, BlockingState, DateTime?>(
          selector: (state) => state.sessionStartedAt,
          builder: (context, sessionStartedAt) {
            return StreamBuilder<DateTime>(
              stream: Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
              initialData: DateTime.now(),
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();
                final duration = switch (sessionStartedAt) {
                  final startedAt? => now.isAfter(startedAt) ? now.difference(startedAt) : Duration.zero,
                  null => Duration.zero,
                };

                return Text(
                  duration.formatTimerHhMmSs(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.displayLarge?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                );
              },
            );
          },
        ),
        BlocSelector<BlockingBloc, BlockingState, bool>(
          selector: (state) => state.isLoading,
          builder: (context, isBusy) {
            return HomeSessionButton(isActiveSession: true, isBusy: isBusy, onTap: () => _onStopPressed(context));
          },
        ),

        Text(
          l10n.homeQuickPauseLabel.toUpperCase(),
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.onSurfaceVariant, letterSpacing: 3),
        ),
        BlocSelector<BlockingBloc, BlockingState, bool>(
          selector: (state) => state.isLoading,
          builder: (context, isBusy) {
            return Row(
              spacing: PauzaSpacing.medium,
              children: <Widget>[
                Expanded(
                  child: HomePausePill(
                    minutes: 1,
                    isBusy: isBusy,
                    onTap: () => _onQuickPausePressed(context, const Duration(minutes: 1)),
                  ),
                ),
                Expanded(
                  child: HomePausePill(
                    minutes: 5,
                    isBusy: isBusy,
                    onTap: () => _onQuickPausePressed(context, const Duration(minutes: 5)),
                  ),
                ),
                Expanded(
                  child: HomePausePill(
                    minutes: 10,
                    isBusy: isBusy,
                    onTap: () => _onQuickPausePressed(context, const Duration(minutes: 10)),
                  ),
                ),
              ],
            );
          },
        ),
        BlocSelector<BlockingBloc, BlockingState, bool>(
          selector: (state) => state.isLoading,
          builder: (context, isBusy) {
            return TextButton(
              onPressed: isBusy ? null : () => _onEmergencyStopPressed(context),
              child: Text(
                l10n.emergencyStopButton,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isBusy ? context.colorScheme.onSurfaceVariant : context.colorScheme.error,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _onStopPressed(BuildContext context) async {
    final proof = await _resolveProof(context);
    if (!context.mounted || proof == null) {
      return;
    }

    context.read<BlockingBloc>().add(BlockingStopRequested(proof: proof));
  }

  Future<void> _onQuickPausePressed(BuildContext context, Duration duration) async {
    final proof = await _resolveProof(context);
    if (!context.mounted || proof == null) {
      return;
    }

    context.read<BlockingBloc>().add(BlockingQuickPauseRequested(duration, proof: proof));
  }

  Future<void> _onEmergencyStopPressed(BuildContext context) async {
    final l10n = context.l10n;
    final emergencyStopRepository = RootScope.of(context).emergencyStopRepository;

    int remaining;
    try {
      remaining = await emergencyStopRepository.getRemainingStops();
    } on Object {
      if (context.mounted) context.showToast(l10n.emergencyStopInternetRequired);
      return;
    }

    if (!context.mounted) return;

    if (remaining <= 0) {
      context.showToast(l10n.emergencyStopNoneRemaining);
      return;
    }

    final confirmed = await ConfirmEmergencyStopDialog.show(context, remainingStops: remaining);
    if (!context.mounted || confirmed != true) return;

    context.read<BlockingBloc>().add(const BlockingEmergencyStopRequested());
  }

  Future<BlockingActionProof?> _resolveProof(BuildContext context) async {
    final mode = context.read<BlockingBloc>().state.activeMode;
    if (mode == null) {
      return const ManualActionProof();
    }

    switch (mode.endingPausingScenario) {
      case ModeEndingPausingScenario.manual:
        return const ManualActionProof();
      case ModeEndingPausingScenario.nfc:
        final nfcCard = await NfcChipScanSheet.show(context);
        if (nfcCard == null) {
          return null;
        }
        return NfcActionProof(chipIdentifier: nfcCard.uidHex);
      case ModeEndingPausingScenario.qrCode:
        final scannedValue = await QrCodeScanSheet.show(context);
        if (scannedValue == null) {
          return null;
        }
        return QrActionProof(rawValue: scannedValue);
    }
  }
}
