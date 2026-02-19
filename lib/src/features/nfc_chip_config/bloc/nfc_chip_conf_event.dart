part of 'nfc_chip_conf_bloc.dart';

sealed class NfcChipConfEvent extends Equatable {
  const NfcChipConfEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class NfcChipLoadCardsRequested extends NfcChipConfEvent {
  const NfcChipLoadCardsRequested();
}

final class NfcChipDeleteCardRequested extends NfcChipConfEvent {
  const NfcChipDeleteCardRequested({required this.cardId});

  final String cardId;

  @override
  List<Object?> get props => [cardId];
}

final class NfcChipLinkCardRequested extends NfcChipConfEvent {
  const NfcChipLinkCardRequested({required this.card});

  final NfcCardDto card;

  @override
  List<Object?> get props => [card];
}

final class NfcChipRenameCardRequested extends NfcChipConfEvent {
  const NfcChipRenameCardRequested({required this.cardId, required this.newName});

  final String cardId;
  final String newName;

  @override
  List<Object?> get props => [cardId, newName];
}
