import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';

abstract interface class NfcRepository {
  bool get isScanInProgress;

  Future<NfcChipAvailability> getAvailability();

  Future<NfcCardDto> scanSingleCard({
    Duration timeout = const Duration(seconds: 20),
  });

  Future<void> stopSession({String? alertMessage, String? errorMessage});
}
