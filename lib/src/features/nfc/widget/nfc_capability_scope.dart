import 'package:flutter/widgets.dart';
import 'package:pauza/src/features/nfc/domain/nfc_capability_controller.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';

class NfcCapabilityScope extends InheritedNotifier<NfcCapabilityController> {
  const NfcCapabilityScope({
    required NfcCapabilityController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static NfcCapabilityScope? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    return listen
        ? context.dependOnInheritedWidgetOfExactType<NfcCapabilityScope>()
        : context.getInheritedWidgetOfExactType<NfcCapabilityScope>();
  }

  static NfcCapabilityScope of(BuildContext context, {bool listen = true}) {
    final scope = maybeOf(context, listen: listen);
    if (scope == null) {
      throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a NfcCapabilityScope of the exact type',
        'out_of_scope',
      );
    }

    return scope;
  }

  static NfcChipAvailability watchAvailability(BuildContext context) {
    return of(context).notifier?.availability ?? NfcChipAvailability.unknown;
  }

  static NfcChipAvailability readAvailability(BuildContext context) {
    return of(context, listen: false).notifier?.availability ??
        NfcChipAvailability.unknown;
  }
}
