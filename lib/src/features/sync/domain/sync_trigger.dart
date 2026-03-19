import 'dart:async';

abstract interface class SyncTrigger {
  void bind({required void Function() onSync});
  void notifyChange();
  void dispose();
}

final class SyncTriggerImpl implements SyncTrigger {
  static const _debounceDuration = Duration(seconds: 2);

  Timer? _debounceTimer;
  void Function()? _onSync;

  @override
  void bind({required void Function() onSync}) {
    _onSync = onSync;
  }

  @override
  void notifyChange() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _onSync?.call();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _onSync = null;
  }
}
