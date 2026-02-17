import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/home/widget/home_content.dart';
import 'package:pauza/src/features/home/widget/home_current_mode_card.dart';
import 'package:pauza/src/features/home/widget/home_start_session_button.dart';
import 'package:pauza/src/features/home/widget/home_stats_pill.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('HomeContent', () {
    testWidgets('renders active session UI when blocking is active', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final modesBloc = _TestModesListBloc();
      final blockingBloc = _TestBlockingBloc();
      blockingBloc.emitForTest(
        BlockingState(
          activeModeId: 'mode-1',
          sessionStartedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      );

      await tester.pumpWidget(
        _TestApp(modesBloc: modesBloc, blockingBloc: blockingBloc),
      );
      await tester.pump();

      expect(find.byType(HomeStatsPill), findsNothing);
      expect(find.byType(HomeCurrentModeCard), findsNothing);
      expect(find.byType(HomeStartSessionButton), findsOneWidget);
      expect(find.text('1m'), findsOneWidget);
      expect(find.text('5m'), findsOneWidget);
      expect(find.text('10m'), findsOneWidget);
      expect(find.text('RESUME'), findsNothing);
      expect(
        tester
            .widget<HomeStartSessionButton>(find.byType(HomeStartSessionButton))
            .isActiveSession,
        isTrue,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(widget.data!),
        ),
        findsOneWidget,
      );

      addTearDown(modesBloc.close);
      addTearDown(blockingBloc.close);
    });

    testWidgets(
      'renders resume button and hides quick pause pills when paused',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 3000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final modesBloc = _TestModesListBloc();
        final blockingBloc = _TestBlockingBloc();
        blockingBloc.emitForTest(
          BlockingState(
            activeModeId: 'mode-1',
            sessionStartedAt: DateTime.now().subtract(const Duration(hours: 1)),
            pausedUntil: DateTime.now().add(const Duration(minutes: 1)),
          ),
        );

        await tester.pumpWidget(
          _TestApp(modesBloc: modesBloc, blockingBloc: blockingBloc),
        );
        await tester.pump();

        expect(find.text('RESUME'), findsOneWidget);
        expect(find.text('1m'), findsNothing);
        expect(find.text('5m'), findsNothing);
        expect(find.text('10m'), findsNothing);

        await tester.tap(find.text('RESUME'));
        await tester.pump();
        expect(blockingBloc.lastEvent, isA<BlockingResumeRequested>());

        addTearDown(modesBloc.close);
        addTearDown(blockingBloc.close);
      },
    );

    testWidgets('renders default home body when session is not active', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final modesBloc = _TestModesListBloc();
      final blockingBloc = _TestBlockingBloc();

      await tester.pumpWidget(
        _TestApp(modesBloc: modesBloc, blockingBloc: blockingBloc),
      );
      await tester.pump();

      expect(find.byType(HomeStatsPill), findsOneWidget);
      expect(find.byType(HomeCurrentModeCard), findsOneWidget);
      expect(find.byType(HomeStartSessionButton), findsOneWidget);
      expect(find.text('1m'), findsNothing);
      expect(
        tester
            .widget<HomeStartSessionButton>(find.byType(HomeStartSessionButton))
            .isActiveSession,
        isFalse,
      );

      addTearDown(modesBloc.close);
      addTearDown(blockingBloc.close);
    });
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.modesBloc, required this.blockingBloc});

  final ModesListBloc modesBloc;
  final BlockingBloc blockingBloc;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: PauzaTheme.light,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ModesListBloc>.value(value: modesBloc),
          BlocProvider<BlockingBloc>.value(value: blockingBloc),
        ],
        child: const HomeContent(),
      ),
    );
  }
}

class _TestModesListBloc extends ModesListBloc {
  _TestModesListBloc() : super(modesRepository: _NoopModesRepository());
}

class _TestBlockingBloc extends BlockingBloc {
  _TestBlockingBloc() : super(blockingRepository: _NoopBlockingRepository());

  BlockingEvent? lastEvent;

  @override
  void add(BlockingEvent event) {
    lastEvent = event;
    super.add(event);
  }

  void emitForTest(BlockingState value) {
    emit(value);
  }
}

class _NoopModesRepository implements ModesRepository {
  @override
  Future<void> createMode(ModeUpsertDTO request) async {}

  @override
  Future<void> deleteMode(String modeId) async {}

  @override
  Future<Mode> getMode(String modeId) async => _mode;

  @override
  Future<List<Mode>> getModes() async => <Mode>[_mode];

  @override
  Future<void> updateMode({
    required String modeId,
    required ModeUpsertDTO request,
  }) async {}

  static final Mode _mode = Mode(
    id: 'mode-1',
    title: 'Mode 1',
    textOnScreen: 'Focus',
    description: null,
    allowedPausesCount: 3,
    icon: ModeIconCatalog.defaultIcon,
    schedule: null,
    blockedAppIds: const ISet<AppIdentifier>.empty(),
    createdAt: DateTime.now().toUtc(),
    updatedAt: DateTime.now().toUtc(),
  );

  @override
  Stream<void> watchModes() => const Stream.empty();

  @override
  void dispose() {}
}

class _NoopBlockingRepository implements BlockingRepository {
  @override
  Future<RestrictionState> getRestrictionSession() async {
    return const RestrictionState(
      isScheduleEnabled: false,
      isInScheduleNow: false,
      pausedUntil: null,
      activeMode: null,
      activeModeSource: RestrictionModeSource.none,
      currentSessionEvents: <RestrictionLifecycleEvent>[],
    );
  }

  @override
  Future<void> pauseBlocking(Duration duration) async {}

  @override
  Future<void> resumeBlocking() async {}

  @override
  Future<void> startBlocking({
    required Mode mode,
    required ShieldConfiguration? shield,
  }) async {}

  @override
  Future<void> stopBlocking() async {}

  @override
  Future<void> syncRestrictionLifecycleEvents() async {}
}
