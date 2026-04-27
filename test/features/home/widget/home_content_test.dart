import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/ai/daily_report/bloc/ai_daily_report_bloc.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/bloc/home_stats_bloc.dart';
import 'package:pauza/src/features/home/model/blocking_action_error.dart';
import 'package:pauza/src/features/home/widget/home_content.dart';
import 'package:pauza/src/features/home/widget/home_current_mode_card.dart';
import 'package:pauza/src/features/home/widget/home_session_button.dart';
import 'package:pauza/src/features/home/widget/home_stats_pill.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/streaks/common/model/streak_snapshot.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('HomeContent', () {
    late MockModesRepository mockModesRepository;
    late MockBlockingRepository mockBlockingRepository;
    late MockNfcLinkedChipsRepository mockNfcLinkedChipsRepository;
    late MockQrLinkedCodesRepository mockQrLinkedCodesRepository;
    late MockStreaksRepository mockStreaksRepository;
    late MockAiRepository mockAiRepository;
    late MockEmergencyStopRepository mockEmergencyStopRepository;
    late MockInternetRequiredGuard mockInternetRequiredGuard;
    late CurrentUserBloc currentUserBloc;

    setUp(() {
      mockModesRepository = MockModesRepository();
      mockBlockingRepository = MockBlockingRepository();
      mockNfcLinkedChipsRepository = MockNfcLinkedChipsRepository();
      mockQrLinkedCodesRepository = MockQrLinkedCodesRepository();
      mockStreaksRepository = MockStreaksRepository();
      mockAiRepository = MockAiRepository();
      mockEmergencyStopRepository = MockEmergencyStopRepository();
      mockInternetRequiredGuard = MockInternetRequiredGuard();

      final mockAuthRepo = MockAuthRepository();
      final mockProfileRepo = MockUserProfileRepository();
      when(() => mockAuthRepo.sessionStream).thenAnswer((_) => const Stream<Session>.empty());
      when(() => mockAuthRepo.currentSession).thenReturn(const Session.empty());
      when(() => mockProfileRepo.watchProfileChanges()).thenAnswer((_) => const Stream<Never>.empty());
      currentUserBloc = CurrentUserBloc(authRepository: mockAuthRepo, userProfileRepository: mockProfileRepo);

      when(() => mockModesRepository.watchModes()).thenAnswer((_) => const Stream<void>.empty());
      when(() => mockModesRepository.getModes()).thenAnswer((_) async => <Mode>[makeMode()]);
      when(() => mockModesRepository.getMode(any())).thenAnswer((_) async => makeMode());
      when(() => mockModesRepository.dispose()).thenReturn(null);

      when(
        () => mockBlockingRepository.lifecycleActions,
      ).thenAnswer((_) => const Stream<RestrictionLifecycleAction>.empty());
      when(() => mockBlockingRepository.getRestrictionSession()).thenAnswer((_) async => makeRestrictionState());
      when(() => mockBlockingRepository.dispose()).thenReturn(null);

      when(
        () => mockStreaksRepository.getGlobalSnapshot(nowLocal: any(named: 'nowLocal')),
      ).thenAnswer((_) async => makeStreakSnapshot());
      when(() => mockStreaksRepository.refreshAggregates()).thenAnswer((_) async {});
    });

    testWidgets('renders default home body when session is not active', (tester) async {
      final modesBloc = _TestModesListBloc(mockModesRepository);
      addTearDown(modesBloc.close);
      final blockingBloc = _TestBlockingBloc(
        blockingRepository: mockBlockingRepository,
        modesRepository: mockModesRepository,
        nfcLinkedChipsRepository: mockNfcLinkedChipsRepository,
        qrLinkedCodesRepository: mockQrLinkedCodesRepository,
        emergencyStopRepository: mockEmergencyStopRepository,
        internetRequiredGuard: mockInternetRequiredGuard,
      );
      addTearDown(blockingBloc.close);

      await tester.pumpApp(
        const HomeContent(),
        surfaceSize: const Size(1200, 3000),
        providers: [
          BlocProvider<CurrentUserBloc>.value(value: currentUserBloc),
          BlocProvider<ModesListBloc>.value(value: modesBloc),
          BlocProvider<BlockingBloc>.value(value: blockingBloc),
          BlocProvider<HomeStatsBloc>(
            create: (context) => HomeStatsBloc(
              streaksRepository: mockStreaksRepository,
              lifecycleActions: const Stream<RestrictionLifecycleAction>.empty(),
            )..add(const HomeStatsLoadRequested()),
          ),
          BlocProvider<AiDailyReportBloc>(create: (context) => AiDailyReportBloc(aiRepository: mockAiRepository)),
        ],
      );

      expect(find.byType(HomeStatsPill), findsOneWidget);
      expect(find.byType(HomeCurrentModeCard), findsOneWidget);
      expect(find.byType(HomeSessionButton), findsOneWidget);
      expect(find.text('1m'), findsNothing);
      expect(tester.widget<HomeSessionButton>(find.byType(HomeSessionButton)).isActiveSession, isFalse);
    });

    testWidgets('renders loaded streak and duration from HomeStatsBloc', (tester) async {
      final modesBloc = _TestModesListBloc(mockModesRepository);
      addTearDown(modesBloc.close);
      final blockingBloc = _TestBlockingBloc(
        blockingRepository: mockBlockingRepository,
        modesRepository: mockModesRepository,
        nfcLinkedChipsRepository: mockNfcLinkedChipsRepository,
        qrLinkedCodesRepository: mockQrLinkedCodesRepository,
        emergencyStopRepository: mockEmergencyStopRepository,
        internetRequiredGuard: mockInternetRequiredGuard,
      );
      addTearDown(blockingBloc.close);

      final snapshotRepo = MockStreaksRepository();
      when(() => snapshotRepo.getGlobalSnapshot(nowLocal: any(named: 'nowLocal'))).thenAnswer(
        (_) async => makeStreakSnapshot(
          currentStreakDays: const CurrentStreakDays(2),
          bestStreakDays: const BestStreakDays(2),
          todayEffectiveDuration: const Duration(minutes: 95),
        ),
      );
      when(() => snapshotRepo.refreshAggregates()).thenAnswer((_) async {});

      await tester.pumpApp(
        const HomeContent(),
        surfaceSize: const Size(1200, 3000),
        providers: [
          BlocProvider<CurrentUserBloc>.value(value: currentUserBloc),
          BlocProvider<ModesListBloc>.value(value: modesBloc),
          BlocProvider<BlockingBloc>.value(value: blockingBloc),
          BlocProvider<HomeStatsBloc>(
            create: (context) => HomeStatsBloc(
              streaksRepository: snapshotRepo,
              lifecycleActions: const Stream<RestrictionLifecycleAction>.empty(),
            )..add(const HomeStatsLoadRequested()),
          ),
          BlocProvider<AiDailyReportBloc>(create: (context) => AiDailyReportBloc(aiRepository: mockAiRepository)),
        ],
      );

      expect(find.text('2 Day Streak'), findsOneWidget);
      expect(find.text('1h 35m'), findsOneWidget);
    });

    testWidgets('renders placeholder while first stats load is in-flight', (tester) async {
      final modesBloc = _TestModesListBloc(mockModesRepository);
      addTearDown(modesBloc.close);
      final blockingBloc = _TestBlockingBloc(
        blockingRepository: mockBlockingRepository,
        modesRepository: mockModesRepository,
        nfcLinkedChipsRepository: mockNfcLinkedChipsRepository,
        qrLinkedCodesRepository: mockQrLinkedCodesRepository,
        emergencyStopRepository: mockEmergencyStopRepository,
        internetRequiredGuard: mockInternetRequiredGuard,
      );
      addTearDown(blockingBloc.close);

      final completer = Completer<StreakSnapshot>();
      final deferredRepo = MockStreaksRepository();
      when(() => deferredRepo.getGlobalSnapshot(nowLocal: any(named: 'nowLocal'))).thenAnswer((_) => completer.future);
      when(() => deferredRepo.refreshAggregates()).thenAnswer((_) async {});

      await tester.pumpApp(
        const HomeContent(),
        surfaceSize: const Size(1200, 3000),
        providers: [
          BlocProvider<CurrentUserBloc>.value(value: currentUserBloc),
          BlocProvider<ModesListBloc>.value(value: modesBloc),
          BlocProvider<BlockingBloc>.value(value: blockingBloc),
          BlocProvider<HomeStatsBloc>(
            create: (context) => HomeStatsBloc(
              streaksRepository: deferredRepo,
              lifecycleActions: const Stream<RestrictionLifecycleAction>.empty(),
            )..add(const HomeStatsLoadRequested()),
          ),
          BlocProvider<AiDailyReportBloc>(create: (context) => AiDailyReportBloc(aiRepository: mockAiRepository)),
        ],
      );

      expect(find.text('--'), findsNWidgets(2));

      completer.complete(
        makeStreakSnapshot(
          currentStreakDays: const CurrentStreakDays(1),
          bestStreakDays: const BestStreakDays(1),
          todayEffectiveDuration: const Duration(minutes: 10),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('1 Day Streak'), findsOneWidget);
      expect(find.text('0h 10m'), findsOneWidget);
    });

    testWidgets('shows toast when pause is blocked by limit', (tester) async {
      final modesBloc = _TestModesListBloc(mockModesRepository);
      addTearDown(modesBloc.close);
      final blockingBloc = _TestBlockingBloc(
        blockingRepository: mockBlockingRepository,
        modesRepository: mockModesRepository,
        nfcLinkedChipsRepository: mockNfcLinkedChipsRepository,
        qrLinkedCodesRepository: mockQrLinkedCodesRepository,
        emergencyStopRepository: mockEmergencyStopRepository,
        internetRequiredGuard: mockInternetRequiredGuard,
      );
      addTearDown(blockingBloc.close);

      await tester.pumpApp(
        const HomeContent(),
        surfaceSize: const Size(1200, 3000),
        providers: [
          BlocProvider<CurrentUserBloc>.value(value: currentUserBloc),
          BlocProvider<ModesListBloc>.value(value: modesBloc),
          BlocProvider<BlockingBloc>.value(value: blockingBloc),
          BlocProvider<HomeStatsBloc>(
            create: (context) => HomeStatsBloc(
              streaksRepository: mockStreaksRepository,
              lifecycleActions: const Stream<RestrictionLifecycleAction>.empty(),
            )..add(const HomeStatsLoadRequested()),
          ),
          BlocProvider<AiDailyReportBloc>(create: (context) => AiDailyReportBloc(aiRepository: mockAiRepository)),
        ],
      );

      blockingBloc.emitForTest(const BlockingState.initial().setError(const PauseLimitReachedError()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Pause limit reached for this session.'), findsOneWidget);
    });

    testWidgets('shows toast for start configuration validation errors', (tester) async {
      final modesBloc = _TestModesListBloc(mockModesRepository);
      addTearDown(modesBloc.close);
      final blockingBloc = _TestBlockingBloc(
        blockingRepository: mockBlockingRepository,
        modesRepository: mockModesRepository,
        nfcLinkedChipsRepository: mockNfcLinkedChipsRepository,
        qrLinkedCodesRepository: mockQrLinkedCodesRepository,
        emergencyStopRepository: mockEmergencyStopRepository,
        internetRequiredGuard: mockInternetRequiredGuard,
      );
      addTearDown(blockingBloc.close);

      await tester.pumpApp(
        const HomeContent(),
        surfaceSize: const Size(1200, 3000),
        providers: [
          BlocProvider<CurrentUserBloc>.value(value: currentUserBloc),
          BlocProvider<ModesListBloc>.value(value: modesBloc),
          BlocProvider<BlockingBloc>.value(value: blockingBloc),
          BlocProvider<HomeStatsBloc>(
            create: (context) => HomeStatsBloc(
              streaksRepository: mockStreaksRepository,
              lifecycleActions: const Stream<RestrictionLifecycleAction>.empty(),
            )..add(const HomeStatsLoadRequested()),
          ),
          BlocProvider<AiDailyReportBloc>(create: (context) => AiDailyReportBloc(aiRepository: mockAiRepository)),
        ],
      );

      blockingBloc.emitForTest(const BlockingState.initial().setError(const NfcStartConfigurationMissingError()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('To start this session, link at least one NFC tag in Settings.'), findsOneWidget);

      blockingBloc.emitForTest(const BlockingState.initial().setError(const QrStartConfigurationMissingError()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('To start this session, link at least one QR code in Settings.'), findsOneWidget);
    });
  });
}

class _TestModesListBloc extends ModesListBloc {
  _TestModesListBloc(MockModesRepository modesRepository) : super(modesRepository: modesRepository);
}

class _TestBlockingBloc extends BlockingBloc {
  _TestBlockingBloc({
    required super.blockingRepository,
    required super.modesRepository,
    required super.nfcLinkedChipsRepository,
    required super.qrLinkedCodesRepository,
    required super.emergencyStopRepository,
    required super.internetRequiredGuard,
  });

  BlockingEvent? lastEvent;

  @override
  void add(BlockingEvent event) {
    lastEvent = event;
    super.add(event);
  }

  void emitForTest(BlockingState value) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(value);
  }
}
