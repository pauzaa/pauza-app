part of 'nfc_chip_conf_bloc.dart';

sealed class NfcChipConfState extends Equatable {
  const NfcChipConfState({required this.linkedChips});
  final IList<NfcLinkedChip> linkedChips;

  bool get isLoading => this is NfcChipConfLoading;
  bool get isError => this is NfcChipConfError;

  NfcChipConfState loading({IList<NfcLinkedChip>? newLinkedChips}) =>
      NfcChipConfLoading(linkedChips: newLinkedChips ?? linkedChips);
  NfcChipConfState setError(Object error, {IList<NfcLinkedChip>? newLinkedChips}) =>
      NfcChipConfError(error: error, linkedChips: newLinkedChips ?? linkedChips);
  NfcChipConfState idle(IList<NfcLinkedChip> newLinkedChips) => NfcChipConfIdle(linkedChips: newLinkedChips);
}

final class NfcChipConfIdle extends NfcChipConfState {
  const NfcChipConfIdle({required super.linkedChips});

  @override
  List<Object?> get props => [linkedChips];
}

final class NfcChipConfLoading extends NfcChipConfState {
  const NfcChipConfLoading({required super.linkedChips});

  @override
  List<Object?> get props => [linkedChips];
}

final class NfcChipConfError extends NfcChipConfState {
  const NfcChipConfError({required this.error, required super.linkedChips});

  final Object? error;

  @override
  List<Object?> get props => [error, linkedChips];
}
