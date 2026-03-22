import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pauza/src/core/common_ui/pauza_assets.dart';

final class PauzaLogoIcon extends StatelessWidget {
  const PauzaLogoIcon({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      PauzaAssets.logo,
      width: size,
      height: size,
    );
  }
}
