import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/domain/nfc_capability_controller.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';
import 'package:pauza/src/features/nfc/widget/nfc_capability_scope.dart';

void main() {
  testWidgets('provides read and watch availability access', (tester) async {
    final repository = _FakeNfcRepository(
      availability: NfcChipAvailability.available,
    );
    final controller = NfcCapabilityController(
      repository: repository,
      minRefreshInterval: Duration.zero,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: NfcCapabilityScope(
          controller: controller,
          child: Builder(
            builder: (context) {
              final watch = NfcCapabilityScope.watchAvailability(context);
              final read = NfcCapabilityScope.readAvailability(context);
              return Text(
                'watch:$watch read:$read',
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.textContaining('available'), findsOneWidget);
  });
}

final class _FakeNfcRepository implements NfcRepository {
  _FakeNfcRepository({required this.availability});

  final NfcChipAvailability availability;

  @override
  bool get isScanInProgress => false;

  @override
  Future<NfcChipAvailability> getAvailability() async => availability;

  @override
  Future<NfcCardDto> scanSingleCard({
    Duration timeout = const Duration(seconds: 20),
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> stopSession({
    String? alertMessage,
    String? errorMessage,
  }) async {}
}
