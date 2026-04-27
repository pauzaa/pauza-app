import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/ai/addiction_check/bloc/ai_addiction_check_bloc.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAiRepository aiRepository;

  setUp(() {
    aiRepository = MockAiRepository();

    when(() => aiRepository.checkAddiction()).thenAnswer((_) async => 'analysis');
  });

  blocTest<AiAddictionCheckBloc, AiAddictionCheckState>(
    'emits analysis after repository returns addiction check',
    build: () => AiAddictionCheckBloc(aiRepository: aiRepository),
    act: (bloc) => bloc.add(const AiAddictionCheckRequested()),
    expect: () => const <AiAddictionCheckState>[
      AiAddictionCheckState(isLoading: true),
      AiAddictionCheckState(analysis: 'analysis'),
    ],
    verify: (_) {
      verify(() => aiRepository.checkAddiction()).called(1);
    },
  );
}
