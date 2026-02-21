part of 'qr_code_conf_bloc.dart';

sealed class QrCodeConfState extends Equatable {
  const QrCodeConfState({required this.linkedCodes});

  final IList<QrLinkedCode> linkedCodes;

  bool get isLoading => this is QrCodeConfLoading;
  bool get isSuccess => this is QrCodeConfSuccess;
  bool get isError => this is QrCodeConfError;

  QrCodeConfState loading({IList<QrLinkedCode>? newLinkedCodes}) =>
      QrCodeConfLoading(linkedCodes: newLinkedCodes ?? linkedCodes);

  QrCodeConfState success({IList<QrLinkedCode>? newLinkedCodes}) =>
      QrCodeConfSuccess(linkedCodes: newLinkedCodes ?? linkedCodes);

  QrCodeConfState setError(Object error, {IList<QrLinkedCode>? newLinkedCodes}) =>
      QrCodeConfError(error: error, linkedCodes: newLinkedCodes ?? linkedCodes);

  QrCodeConfState idle(IList<QrLinkedCode> newLinkedCodes) => QrCodeConfIdle(linkedCodes: newLinkedCodes);
}

final class QrCodeConfIdle extends QrCodeConfState {
  const QrCodeConfIdle({required super.linkedCodes});

  @override
  List<Object?> get props => const <Object?>[];
}

final class QrCodeConfLoading extends QrCodeConfState {
  const QrCodeConfLoading({required super.linkedCodes});

  @override
  List<Object?> get props => const <Object?>[];
}

final class QrCodeConfSuccess extends QrCodeConfState {
  const QrCodeConfSuccess({required super.linkedCodes});

  @override
  List<Object?> get props => const <Object?>[];
}

final class QrCodeConfError extends QrCodeConfState {
  const QrCodeConfError({required this.error, required super.linkedCodes});

  final Object? error;

  @override
  List<Object?> get props => [error];
}
