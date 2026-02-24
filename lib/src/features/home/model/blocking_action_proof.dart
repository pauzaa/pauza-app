import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';

@immutable
sealed class BlockingActionProof {
  const BlockingActionProof();
}

final class ManualActionProof extends BlockingActionProof {
  const ManualActionProof();
}

final class NfcActionProof extends BlockingActionProof {
  const NfcActionProof({required this.chipIdentifier});

  final NfcChipIdentifier? chipIdentifier;
}

final class QrActionProof extends BlockingActionProof {
  const QrActionProof({required this.rawValue});

  final String rawValue;
}
