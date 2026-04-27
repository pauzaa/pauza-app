import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/ai/usage_analysis/bloc/ai_usage_analysis_bloc.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAiRepository aiRepository;

  setUpAll(() {
    registerFallbackValue(DateTimeRange(start: DateTime(2026), end: DateTime(2026, 1, 2)));
  });

  setUp(() {
    aiRepository = MockAiRepository();

    when(() => aiRepository.analyzeUsage(window: any(named: 'window'))).thenAnswer((_) async => 'analysis');
  });

  blocTest<AiUsageAnalysisBloc, AiUsageAnalysisState>(
    'emits analysis after repository returns usage analysis',
    build: () => AiUsageAnalysisBloc(aiRepository: aiRepository),
    act: (bloc) => bloc.add(
      AiUsageAnalysisRequested(
        window: DateTimeRange(start: DateTime(2026, 3), end: DateTime(2026, 3, 30).dayEnd),
      ),
    ),
    expect: () => const <AiUsageAnalysisState>[
      AiUsageAnalysisState(isLoading: true),
      AiUsageAnalysisState(analysis: 'analysis'),
    ],
    verify: (_) {
      final window =
          verify(() => aiRepository.analyzeUsage(window: captureAny(named: 'window'))).captured.single as DateTimeRange;

      expect(window, DateTimeRange(start: DateTime(2026, 3), end: DateTime(2026, 3, 30).dayEnd));
    },
  );
}
