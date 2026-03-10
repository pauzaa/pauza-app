import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/list/widget/mode_list_item.dart';

import '../../../../helpers/helpers.dart';

void main() {
  testWidgets('renders mode icon token in list item', (tester) async {
    final mode = makeMode(title: 'Focus', textOnScreen: 'Stay focused', icon: ModeIcon.fromToken('ms:v1:nightlight'));

    await tester.pumpApp(
      Scaffold(
        body: ModeListItem(mode: mode, isSelected: false, onTap: () {}, onEdit: () {}, onDelete: () {}),
      ),
    );

    expect(find.byWidgetPredicate((widget) => widget is Icon && widget.icon == mode.icon.icon), findsOneWidget);
  });
}
