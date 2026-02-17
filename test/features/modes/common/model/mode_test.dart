import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';

void main() {
  group('Mode.fromDbRow', () {
    test('falls back to default icon token for invalid db value', () {
      final mode = Mode.fromDbRow(<String, Object?>{
        'id': 'mode-1',
        'title': 'Focus',
        'text_on_screen': 'Stay focused',
        'description': null,
        'allowed_pauses_count': 1,
        'icon_token': 'invalid',
        'created_at': DateTime.now().toUtc().millisecondsSinceEpoch,
        'updated_at': DateTime.now().toUtc().millisecondsSinceEpoch,
        'schedule_days': null,
        'schedule_start_minute': null,
        'schedule_end_minute': null,
        'schedule_enabled': null,
        'blocked_apps': null,
      });

      expect(mode.icon, ModeIconCatalog.defaultIcon);
    });
  });
}
