import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/home/widget/home_current_mode_card.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';

import '../../../helpers/helpers.dart';

void main() {
  testWidgets('renders selected mode icon token', (tester) async {
    final mode = makeMode(icon: ModeIcon.fromToken('ms:v1:rocket_launch'));

    await tester.pumpApp(Scaffold(body: HomeCurrentModeCard(mode, onTap: () {})));

    final icon = tester.widget<Icon>(
      find.byWidgetPredicate((widget) => widget is Icon && widget.icon == mode.icon.icon),
    );

    expect(icon.icon, mode.icon.icon);
  });
}
