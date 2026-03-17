import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/ai/daily_report/widget/ai_daily_report_card.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/bloc/home_stats_bloc.dart';
import 'package:pauza/src/features/home/widget/home_current_mode_card.dart';
import 'package:pauza/src/features/home/widget/home_session_button.dart';
import 'package:pauza/src/features/home/widget/home_stats_pill.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza/src/features/modes/list/widget/mode_picker_sheet.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class HomeDefaultWidget extends StatelessWidget {
  const HomeDefaultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        BlocSelector<HomeStatsBloc, HomeStatsState, ({int? streakDays, Duration? focusedDuration})>(
          selector: (state) => (streakDays: state.streakDays, focusedDuration: state.focusedDuration),
          builder: (context, stats) {
            return Center(
              child: HomeStatsPill(streakDays: stats.streakDays, focusedDuration: stats.focusedDuration),
            );
          },
        ),
        const SizedBox(height: PauzaSpacing.extraLarge),
        BlocSelector<ModesListBloc, ModesListState, Mode?>(
          selector: (state) => state.selectedMode,
          builder: (context, effectiveMode) {
            return BlocSelector<BlockingBloc, BlockingState, bool>(
              selector: (state) => state.isLoading,
              builder: (context, isBusy) {
                return HomeSessionButton(
                  isBusy: isBusy,
                  onTap: () => _onStartPressed(context: context, mode: effectiveMode, isBlocking: false),
                );
              },
            );
          },
        ),
        const SizedBox(height: PauzaSpacing.extraLarge),
        BlocBuilder<ModesListBloc, ModesListState>(
          builder: (context, modesState) {
            return HomeCurrentModeCard(
              modesState.selectedMode,
              onTap: () => _onCurrentModePressed(context, modesState.items, modesState.selectedMode),
            );
          },
        ),
        const SizedBox(height: PauzaSpacing.extraLarge),
        const AiDailyReportCard(),
      ],
    );
  }

  Future<void> _onCurrentModePressed(BuildContext context, List<Mode> modes, Mode? selectedMode) async {
    final pickedMode = await ModePickerSheet.show(context, modes: modes, activeModeId: selectedMode?.id);
    if (pickedMode == null || !context.mounted) {
      return;
    }

    context.read<ModesListBloc>().add(ModesSelectionRequested(modeId: pickedMode.id));
  }

  void _onStartPressed({required BuildContext context, required Mode? mode, required bool isBlocking}) {
    if (isBlocking) {
      context.showToast(context.l10n.alreadyBlocking);
      return;
    }

    if (mode == null) {
      context.showToast(context.l10n.selectMode);
      return;
    }
    context.read<BlockingBloc>().add(BlockingStartRequested(mode));
  }
}
