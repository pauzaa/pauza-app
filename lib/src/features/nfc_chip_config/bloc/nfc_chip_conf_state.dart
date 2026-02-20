part of 'nfc_chip_conf_bloc.dart';

sealed class NfcChipConfState extends Equatable {
  const NfcChipConfState({required this.linkedChips});
  final IList<NfcLinkedChip> linkedChips;

  bool get isLoading => this is NfcChipConfLoading;
  bool get isSuccess => this is NfcChipConfSuccess;
  bool get isError => this is NfcChipConfError;

  NfcChipConfState loading({IList<NfcLinkedChip>? newLinkedChips}) =>
      NfcChipConfLoading(linkedChips: newLinkedChips ?? linkedChips);
  NfcChipConfState success({IList<NfcLinkedChip>? newLinkedChips}) =>
      NfcChipConfSuccess(linkedChips: newLinkedChips ?? linkedChips);
  NfcChipConfState setError(Object error, {IList<NfcLinkedChip>? newLinkedChips}) =>
      NfcChipConfError(error: error, linkedChips: newLinkedChips ?? linkedChips);
  NfcChipConfState idle(IList<NfcLinkedChip> newLinedList) => NfcChipConfIdle(linkedChips: newLinedList);
}

final class NfcChipConfIdle extends NfcChipConfState {
  const NfcChipConfIdle({required super.linkedChips});

  @override
  List<Object?> get props => const <Object?>[];
}

final class NfcChipConfLoading extends NfcChipConfState {
  const NfcChipConfLoading({required super.linkedChips});

  @override
  List<Object?> get props => const <Object?>[];
}

final class NfcChipConfSuccess extends NfcChipConfState {
  const NfcChipConfSuccess({required super.linkedChips});

  @override
  List<Object?> get props => const <Object?>[];
}

final class NfcChipConfError extends NfcChipConfState {
  const NfcChipConfError({required this.error, required super.linkedChips});

  final Object? error;

  @override
  List<Object?> get props => [error];
}
