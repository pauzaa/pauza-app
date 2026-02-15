import 'dart:io';

/// Platform key used in local DB records.
///
final PauzaPlatform kPauzaPlatform = Platform.isIOS
    ? PauzaPlatform.ios
    : PauzaPlatform.android;

enum PauzaPlatform {
  android('android'),
  ios('ios');

  const PauzaPlatform(this.dbValue);

  final String dbValue;

  static PauzaPlatform get current =>
      Platform.isIOS ? PauzaPlatform.ios : PauzaPlatform.android;
}
