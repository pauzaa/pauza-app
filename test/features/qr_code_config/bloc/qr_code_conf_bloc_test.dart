import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/qr_code_config/bloc/qr_code_conf_bloc.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_linked_codes_repository.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_unlock_token.dart';

void main() {
  group('QrCodeConfState semantics', () {
    test('idle and loading state equality includes linkedCodes', () {
      final firstCodes = [_code(id: 'code-1', name: 'Desk')].lock;
      final secondCodes = [_code(id: 'code-2', name: 'Office')].lock;

      expect(QrCodeConfIdle(linkedCodes: firstCodes), isNot(QrCodeConfIdle(linkedCodes: secondCodes)));
      expect(QrCodeConfLoading(linkedCodes: firstCodes), isNot(QrCodeConfLoading(linkedCodes: secondCodes)));
    });

    test('error state equality includes both error and linkedCodes', () {
      final error = StateError('failed');
      final firstCodes = [_code(id: 'code-1', name: 'Desk')].lock;
      final secondCodes = [_code(id: 'code-2', name: 'Office')].lock;

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
    test('load success emits idle with fetched codes', () async {
      final repository = _FakeQrLinkedCodesRepository(
        linkedCodes: [_code(id: 'code-1', name: 'Desk')].lock,
      );
      final bloc = QrCodeConfBloc(linkedCodesRepository: repository);
      final emitted = <QrCodeConfState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const QrCodeLoadCodesRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted.whereType<QrCodeConfLoading>(), isNotEmpty);
      expect(bloc.state, isA<QrCodeConfIdle>());
      expect(bloc.state.linkedCodes.length, 1);

      await sub.cancel();
      await bloc.close();
    });

    test('load error emits error state', () async {
      final repository = _FakeQrLinkedCodesRepository(getLinkedCodesError: StateError('load_failed'));
      final bloc = QrCodeConfBloc(linkedCodesRepository: repository);

      bloc.add(const QrCodeLoadCodesRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<QrCodeConfError>());

      await bloc.close();
    });

    test('generate success calls repository and reloads list', () async {
      final repository = _FakeQrLinkedCodesRepository(
        linkedCodesByCall: <IList<QrLinkedCode>>[
          [_code(id: 'code-2', name: 'New')].lock,
        ],
      );
      final bloc = QrCodeConfBloc(linkedCodesRepository: repository);

      bloc.add(const QrCodeGenerateCodeRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.generateCalls, 1);
      expect(bloc.state, isA<QrCodeConfIdle>());
      expect(bloc.state.linkedCodes.length, 1);

      await bloc.close();
    });

    test('generate error emits error state', () async {
      final repository = _FakeQrLinkedCodesRepository(generateError: StateError('generate_failed'));
      final bloc = QrCodeConfBloc(linkedCodesRepository: repository);

      bloc.add(const QrCodeGenerateCodeRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<QrCodeConfError>());

      await bloc.close();
    });

    test('loading to error transition retains linked codes', () async {
      final expectedCode = _code(id: 'code-1', name: 'Desk');
      final repository = _FakeQrLinkedCodesRepository(
        linkedCodes: [expectedCode].lock,
        generateError: StateError('generate_failed'),
      );
      final bloc = QrCodeConfBloc(linkedCodesRepository: repository);

      bloc.add(const QrCodeLoadCodesRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const QrCodeGenerateCodeRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<QrCodeConfError>());
      expect(bloc.state.linkedCodes, [expectedCode].lock);

      await bloc.close();
    });

    test('rename success calls repository and reloads list', () async {
      final repository = _FakeQrLinkedCodesRepository(
        linkedCodesByCall: <IList<QrLinkedCode>>[
          [_code(id: 'code-1', name: 'Updated')].lock,
        ],
      );
      final bloc = QrCodeConfBloc(linkedCodesRepository: repository);

      bloc.add(const QrCodeRenameCodeRequested(codeId: 'code-1', newName: 'Updated'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.renameCalls, 1);
      expect(repository.lastRenameId, 'code-1');
      expect(repository.lastRenameName, 'Updated');
      expect(bloc.state, isA<QrCodeConfIdle>());

      await bloc.close();
    });

    test('rename error emits error state', () async {
      final repository = _FakeQrLinkedCodesRepository(renameError: StateError('rename_failed'));
      final bloc = QrCodeConfBloc(linkedCodesRepository: repository);

      bloc.add(const QrCodeRenameCodeRequested(codeId: 'code-1', newName: 'Updated'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<QrCodeConfError>());

      await bloc.close();
    });

    test('delete success calls repository and reloads list', () async {
      final repository = _FakeQrLinkedCodesRepository(linkedCodesByCall: <IList<QrLinkedCode>>[const IList.empty()]);
      final bloc = QrCodeConfBloc(linkedCodesRepository: repository);

      bloc.add(const QrCodeDeleteCodeRequested(codeId: 'code-1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.deleteCalls, 1);
      expect(repository.lastDeleteId, 'code-1');
      expect(bloc.state, isA<QrCodeConfIdle>());

      await bloc.close();
    });

    test('delete error emits error state', () async {
      final repository = _FakeQrLinkedCodesRepository(deleteError: StateError('delete_failed'));
      final bloc = QrCodeConfBloc(linkedCodesRepository: repository);

      bloc.add(const QrCodeDeleteCodeRequested(codeId: 'code-1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<QrCodeConfError>());

      await bloc.close();
    });
  });
}

final class _FakeQrLinkedCodesRepository implements QrLinkedCodesRepository {
  _FakeQrLinkedCodesRepository({
    IList<QrLinkedCode>? linkedCodes,
    this.linkedCodesByCall,
    this.getLinkedCodesError,
    this.generateError,
    this.renameError,
    this.deleteError,
  }) : linkedCodes = linkedCodes ?? const IList.empty();

  final IList<QrLinkedCode> linkedCodes;
  final List<IList<QrLinkedCode>>? linkedCodesByCall;
  final Object? getLinkedCodesError;
  final Object? generateError;
  final Object? renameError;
  final Object? deleteError;

  var _getLinkedCodesCallIndex = 0;

  var generateCalls = 0;
  var renameCalls = 0;
  var deleteCalls = 0;

  String? lastRenameId;
  String? lastRenameName;
  String? lastDeleteId;

  @override
  Future<IList<QrLinkedCode>> getLinkedCodes() async {
    if (getLinkedCodesError != null) {
      throw getLinkedCodesError!;
    }

    if (linkedCodesByCall case final entries?) {
      final index = _getLinkedCodesCallIndex;
      _getLinkedCodesCallIndex += 1;
      if (index < entries.length) {
        return entries[index];
      }
      return entries.last;
    }

    return linkedCodes;
  }

  @override
  Future<QrLinkedCode> generateAndLinkCode() async {
    generateCalls += 1;
    if (generateError != null) {
      throw generateError!;
    }

    return _code(id: 'generated-id', name: 'generated-name');
  }

  @override
  Future<void> renameCode({required String id, required String name}) async {
    renameCalls += 1;
    lastRenameId = id;
    lastRenameName = name;
    if (renameError != null) {
      throw renameError!;
    }
  }

  @override
  Future<void> deleteCode({required String id}) async {
    deleteCalls += 1;
    lastDeleteId = id;
    if (deleteError != null) {
      throw deleteError!;
    }
  }

  @override
  Future<bool> hasScanValue({required String scanValue}) async {
    return false;
  }
}

QrLinkedCode _code({required String id, required String name}) {
  final now = DateTime.utc(2023, 10, 24);
  return QrLinkedCode(
    id: id,
    scanValue: QrUnlockToken.parse('pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301'),
    name: name,
    createdAt: now,
    updatedAt: now,
  );
}
