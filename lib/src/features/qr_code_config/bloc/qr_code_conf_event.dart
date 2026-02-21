part of 'qr_code_conf_bloc.dart';

sealed class QrCodeConfEvent extends Equatable {
  const QrCodeConfEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class QrCodeLoadCodesRequested extends QrCodeConfEvent {
  const QrCodeLoadCodesRequested();
}

final class QrCodeGenerateCodeRequested extends QrCodeConfEvent {
  const QrCodeGenerateCodeRequested();
}

final class QrCodeRenameCodeRequested extends QrCodeConfEvent {
  const QrCodeRenameCodeRequested({required this.codeId, required this.newName});

  final String codeId;
  final String newName;

  @override
  List<Object?> get props => [codeId, newName];
}

final class QrCodeDeleteCodeRequested extends QrCodeConfEvent {
  const QrCodeDeleteCodeRequested({required this.codeId});

  final String codeId;

  @override
  List<Object?> get props => [codeId];
}
