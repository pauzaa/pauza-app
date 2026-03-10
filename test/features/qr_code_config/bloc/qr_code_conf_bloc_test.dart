import 'package:bloc_test/bloc_test.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/qr_code_config/bloc/qr_code_conf_bloc.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockQrLinkedCodesRepository repository;

  setUpAll(registerTestFallbackValues);

  setUp(() {
    repository = MockQrLinkedCodesRepository();
  });

  group('QrCodeConfState semantics', () {
    test('idle and loading state equality includes linkedCodes', () {
      final firstCodes = [makeQrLinkedCode(id: 'code-1', name: 'Desk')].lock;
      final secondCodes = [makeQrLinkedCode(id: 'code-2', name: 'Office')].lock;

      expect(QrCodeConfIdle(linkedCodes: firstCodes), isNot(QrCodeConfIdle(linkedCodes: secondCodes)));
      expect(QrCodeConfLoading(linkedCodes: firstCodes), isNot(QrCodeConfLoading(linkedCodes: secondCodes)));
    });

    test('error state equality includes both error and linkedCodes', () {
      final error = StateError('failed');
      final firstCodes = [makeQrLinkedCode(id: 'code-1', name: 'Desk')].lock;
      final secondCodes = [makeQrLinkedCode(id: 'code-2', name: 'Office')].lock;

      expect(
        QrCodeConfError(error: error, linkedCodes: firstCodes),
        QrCodeConfError(error: error, linkedCodes: firstCodes),
      );
      expect(
        QrCodeConfError(error: error, linkedCodes: firstCodes),
        isNot(QrCodeConfError(error: error, linkedCodes: secondCodes)),
      );
      expect(
        QrCodeConfError(error: StateError('failed'), linkedCodes: firstCodes),
        isNot(QrCodeConfError(error: StateError('failed-2'), linkedCodes: firstCodes)),
      );
    });
  });

  group('QrCodeConfBloc', () {
    blocTest<QrCodeConfBloc, QrCodeConfState>(
      'load success emits loading then idle with fetched codes',
      setUp: () {
        when(
          () => repository.getLinkedCodes(),
        ).thenAnswer((_) async => [makeQrLinkedCode(id: 'code-1', name: 'Desk')].lock);
      },
      build: () => QrCodeConfBloc(linkedCodesRepository: repository),
      act: (bloc) => bloc.add(const QrCodeLoadCodesRequested()),
      expect: () => <QrCodeConfState>[
        const QrCodeConfLoading(linkedCodes: IList.empty()),
        QrCodeConfIdle(
          linkedCodes: [makeQrLinkedCode(id: 'code-1', name: 'Desk')].lock,
        ),
      ],
      verify: (_) {
        verify(() => repository.getLinkedCodes()).called(1);
      },
    );

    final loadError = StateError('load_failed');
    blocTest<QrCodeConfBloc, QrCodeConfState>(
      'load error emits error state',
      setUp: () {
        when(() => repository.getLinkedCodes()).thenThrow(loadError);
      },
      build: () => QrCodeConfBloc(linkedCodesRepository: repository),
      act: (bloc) => bloc.add(const QrCodeLoadCodesRequested()),
      expect: () => <QrCodeConfState>[
        const QrCodeConfLoading(linkedCodes: IList.empty()),
        QrCodeConfError(error: loadError, linkedCodes: const IList.empty()),
      ],
    );

    blocTest<QrCodeConfBloc, QrCodeConfState>(
      'generate success calls repository and reloads list',
      setUp: () {
        when(() => repository.generateAndLinkCode()).thenAnswer((_) async => makeQrLinkedCode(id: 'generated-id'));
        when(
          () => repository.getLinkedCodes(),
        ).thenAnswer((_) async => [makeQrLinkedCode(id: 'code-2', name: 'New')].lock);
      },
      build: () => QrCodeConfBloc(linkedCodesRepository: repository),
      act: (bloc) => bloc.add(const QrCodeGenerateCodeRequested()),
      expect: () => <QrCodeConfState>[
        const QrCodeConfLoading(linkedCodes: IList.empty()),
        QrCodeConfIdle(
          linkedCodes: [makeQrLinkedCode(id: 'code-2', name: 'New')].lock,
        ),
      ],
      verify: (_) {
        verify(() => repository.generateAndLinkCode()).called(1);
        verify(() => repository.getLinkedCodes()).called(1);
      },
    );

    final generateError = StateError('generate_failed');
    blocTest<QrCodeConfBloc, QrCodeConfState>(
      'generate error emits error state',
      setUp: () {
        when(() => repository.generateAndLinkCode()).thenThrow(generateError);
      },
      build: () => QrCodeConfBloc(linkedCodesRepository: repository),
      act: (bloc) => bloc.add(const QrCodeGenerateCodeRequested()),
      expect: () => <QrCodeConfState>[
        const QrCodeConfLoading(linkedCodes: IList.empty()),
        QrCodeConfError(error: generateError, linkedCodes: const IList.empty()),
      ],
    );

    final transitionError = StateError('generate_failed');
    blocTest<QrCodeConfBloc, QrCodeConfState>(
      'loading to error transition retains linked codes',
      setUp: () {
        when(
          () => repository.getLinkedCodes(),
        ).thenAnswer((_) async => [makeQrLinkedCode(id: 'code-1', name: 'Desk')].lock);
        when(() => repository.generateAndLinkCode()).thenThrow(transitionError);
      },
      build: () => QrCodeConfBloc(linkedCodesRepository: repository),
      act: (bloc) async {
        bloc.add(const QrCodeLoadCodesRequested());
        await bloc.stream.firstWhere((state) => state is QrCodeConfIdle);
        bloc.add(const QrCodeGenerateCodeRequested());
      },
      expect: () {
        final codes = [makeQrLinkedCode(id: 'code-1', name: 'Desk')].lock;
        return <QrCodeConfState>[
          const QrCodeConfLoading(linkedCodes: IList.empty()),
          QrCodeConfIdle(linkedCodes: codes),
          QrCodeConfLoading(linkedCodes: codes),
          QrCodeConfError(error: transitionError, linkedCodes: codes),
        ];
      },
    );

    blocTest<QrCodeConfBloc, QrCodeConfState>(
      'rename success calls repository and reloads list',
      setUp: () {
        when(
          () => repository.renameCode(
            id: any(named: 'id'),
            name: any(named: 'name'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => repository.getLinkedCodes(),
        ).thenAnswer((_) async => [makeQrLinkedCode(id: 'code-1', name: 'Updated')].lock);
      },
      build: () => QrCodeConfBloc(linkedCodesRepository: repository),
      act: (bloc) => bloc.add(const QrCodeRenameCodeRequested(codeId: 'code-1', newName: 'Updated')),
      expect: () => <QrCodeConfState>[
        const QrCodeConfLoading(linkedCodes: IList.empty()),
        QrCodeConfIdle(
          linkedCodes: [makeQrLinkedCode(id: 'code-1', name: 'Updated')].lock,
        ),
      ],
      verify: (_) {
        verify(() => repository.renameCode(id: 'code-1', name: 'Updated')).called(1);
        verify(() => repository.getLinkedCodes()).called(1);
      },
    );

    final renameError = StateError('rename_failed');
    blocTest<QrCodeConfBloc, QrCodeConfState>(
      'rename error emits error state',
      setUp: () {
        when(
          () => repository.renameCode(
            id: any(named: 'id'),
            name: any(named: 'name'),
          ),
        ).thenThrow(renameError);
      },
      build: () => QrCodeConfBloc(linkedCodesRepository: repository),
      act: (bloc) => bloc.add(const QrCodeRenameCodeRequested(codeId: 'code-1', newName: 'Updated')),
      expect: () => <QrCodeConfState>[
        const QrCodeConfLoading(linkedCodes: IList.empty()),
        QrCodeConfError(error: renameError, linkedCodes: const IList.empty()),
      ],
    );

    blocTest<QrCodeConfBloc, QrCodeConfState>(
      'delete success calls repository and reloads list',
      setUp: () {
        when(() => repository.deleteCode(id: any(named: 'id'))).thenAnswer((_) async {});
        when(() => repository.getLinkedCodes()).thenAnswer((_) async => const IList<QrLinkedCode>.empty());
      },
      build: () => QrCodeConfBloc(linkedCodesRepository: repository),
      act: (bloc) => bloc.add(const QrCodeDeleteCodeRequested(codeId: 'code-1')),
      expect: () => <QrCodeConfState>[
        const QrCodeConfLoading(linkedCodes: IList.empty()),
        const QrCodeConfIdle(linkedCodes: IList.empty()),
      ],
      verify: (_) {
        verify(() => repository.deleteCode(id: 'code-1')).called(1);
        verify(() => repository.getLinkedCodes()).called(1);
      },
    );

    final deleteError = StateError('delete_failed');
    blocTest<QrCodeConfBloc, QrCodeConfState>(
      'delete error emits error state',
      setUp: () {
        when(() => repository.deleteCode(id: any(named: 'id'))).thenThrow(deleteError);
      },
      build: () => QrCodeConfBloc(linkedCodesRepository: repository),
      act: (bloc) => bloc.add(const QrCodeDeleteCodeRequested(codeId: 'code-1')),
      expect: () => <QrCodeConfState>[
        const QrCodeConfLoading(linkedCodes: IList.empty()),
        QrCodeConfError(error: deleteError, linkedCodes: const IList.empty()),
      ],
    );
  });
}
