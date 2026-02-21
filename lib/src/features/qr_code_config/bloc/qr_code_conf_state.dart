part of 'qr_code_conf_bloc.dart';

sealed class QrCodeConfState extends Equatable {
  const QrCodeConfState({required this.linkedCodes});

  final IList<QrLinkedCode> linkedCodes;

  bool get isLoading => this is QrCodeConfLoading;
  bool get isError => this is QrCodeConfError;

  QrCodeConfState loading({IList<QrLinkedCode>? linkedCodesOverride}) =>
      QrCodeConfLoading(linkedCodes: linkedCodesOverride ?? linkedCodes);

  QrCodeConfState setError(Object error, {IList<QrLinkedCode>? linkedCodesOverride}) =>
      QrCodeConfError(error: error, linkedCodes: linkedCodesOverride ?? linkedCodes);

  QrCodeConfState idle(IList<QrLinkedCode> updatedLinkedCodes) => QrCodeConfIdle(linkedCodes: updatedLinkedCodes);
}

final class QrCodeConfIdle extends QrCodeConfState {
  const QrCodeConfIdle({required super.linkedCodes});

  @override
  List<Object?> get props => [linkedCodes];
}

final class QrCodeConfLoading extends QrCodeConfState {
  const QrCodeConfLoading({required super.linkedCodes});

  @override
  List<Object?> get props => [linkedCodes];
}

final class QrCodeConfError extends QrCodeConfState {
  const QrCodeConfError({required this.error, required super.linkedCodes});

  final Object? error;

  @override
  List<Object?> get props => [error, linkedCodes];
}
