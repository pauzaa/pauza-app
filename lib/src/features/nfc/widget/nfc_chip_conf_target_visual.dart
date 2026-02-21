import 'package:flutter/material.dart';
import 'package:pauza/src/features/nfc/widget/nfc_target_ring.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class NfcChipConfTargetVisual extends StatelessWidget {
  const NfcChipConfTargetVisual({this.size = 320, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          NfcTargetRing(size: size, color: colorScheme.primary.withValues(alpha: 0.30)),
          NfcTargetRing(size: size * 0.85, color: colorScheme.primary.withValues(alpha: 0.40)),
          NfcTargetRing(size: size * 0.7, color: colorScheme.primary.withValues(alpha: 0.50)),
          SizedBox(
            width: size * 0.50,
            height: size * 0.50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PauzaCornerRadius.xxLarge),
                color: colorScheme.primary.withValues(alpha: 0.20),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.7), width: 1.5),
              ),

              child: Icon(Icons.nfc_rounded, size: size * 0.25, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
