import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/domain/nfc_capability_controller.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NfcCapabilityController', () {
    test('refresh updates availability and notifies listeners', () async {
      final repository = _FakeNfcRepository(
        availability: NfcChipAvailability.available,
      );
      final controller = NfcCapabilityController(
        repository: repository,
        minRefreshInterval: Duration.zero,
      );
      addTearDown(controller.dispose);

      var notifyCount = 0;
      controller.addListener(() {
        notifyCount += 1;
      });

      await controller.refresh(force: true);

      expect(controller.availability, NfcChipAvailability.available);
      expect(notifyCount, greaterThan(0));
    });

    test('sets unknown on refresh errors', () async {
      final repository = _FakeNfcRepository(
        availability: NfcChipAvailability.available,
      );
      final controller = NfcCapabilityController(
        repository: repository,
        minRefreshInterval: Duration.zero,
      );
      addTearDown(controller.dispose);

      await controller.refresh(force: true);
      repository.shouldThrowOnAvailability = true;

      await controller.refresh(force: true);

      expect(controller.availability, NfcChipAvailability.unknown);
    });
  });
}

final class _FakeNfcRepository implements NfcRepository {
  _FakeNfcRepository({required this.availability});

  NfcChipAvailability availability;
  bool shouldThrowOnAvailability = false;

  @override
  bool get isScanInProgress => false;

  @override
  Future<NfcChipAvailability> getAvailability() async {
    if (shouldThrowOnAvailability) {
      throw StateError('boom');
    }

    return availability;
  }

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
