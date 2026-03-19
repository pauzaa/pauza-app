import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/sync/domain/sync_trigger.dart';

void main() {
  group('SyncTriggerImpl', () {
    test('notifyChange before bind is a no-op', () {
      fakeAsync((async) {
        final trigger = SyncTriggerImpl();
        var callCount = 0;

        // Call notifyChange before bind — should not crash or callback.
        trigger.notifyChange();
        async.elapse(const Duration(seconds: 3));

        trigger.bind(onSync: () => callCount++);
        async.elapse(const Duration(seconds: 3));

        expect(callCount, 0);
        trigger.dispose();
      });
    });

    test('fires callback after debounce duration', () {
      fakeAsync((async) {
        final trigger = SyncTriggerImpl();
        var callCount = 0;
        trigger.bind(onSync: () => callCount++);

        trigger.notifyChange();
        expect(callCount, 0);

        async.elapse(const Duration(seconds: 1));
        expect(callCount, 0);

        async.elapse(const Duration(seconds: 1));
        expect(callCount, 1);

        trigger.dispose();
      });
    });

    test('debounces rapid changes into single callback', () {
      fakeAsync((async) {
        final trigger = SyncTriggerImpl();
        var callCount = 0;
        trigger.bind(onSync: () => callCount++);

        trigger.notifyChange();
        async.elapse(const Duration(milliseconds: 500));
        trigger.notifyChange();
        async.elapse(const Duration(milliseconds: 500));
        trigger.notifyChange();
        async.elapse(const Duration(milliseconds: 500));

        expect(callCount, 0);

        async.elapse(const Duration(seconds: 2));
        expect(callCount, 1);

        trigger.dispose();
      });
    });

    test('dispose cancels pending timer', () {
      fakeAsync((async) {
        final trigger = SyncTriggerImpl();
        var callCount = 0;
        trigger.bind(onSync: () => callCount++);

        trigger.notifyChange();
        trigger.dispose();

        async.elapse(const Duration(seconds: 3));
        expect(callCount, 0);
      });
    });

    test('fires again after previous debounce completes', () {
      fakeAsync((async) {
        final trigger = SyncTriggerImpl();
        var callCount = 0;
        trigger.bind(onSync: () => callCount++);

        trigger.notifyChange();
        async.elapse(const Duration(seconds: 2));
        expect(callCount, 1);

        trigger.notifyChange();
        async.elapse(const Duration(seconds: 2));
        expect(callCount, 2);

        trigger.dispose();
      });
    });
  });
}
