import 'package:flutter/foundation.dart';

/// Platform key used in local DB records.
enum PauzaPlatform {
  android('android'),
  ios('ios');

  const PauzaPlatform(this.dbValue);

  final String dbValue;

  static PauzaPlatform get current => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => PauzaPlatform.ios,
    _ => PauzaPlatform.android,
  };
}
