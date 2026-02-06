import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class BlockingRepository {
  Future<List<String>> getRestrictedAppIds();

  Future<void> startBlocking({
    required ShieldConfiguration shield,
    required List<String> appIds,
  });

  Future<void> stopBlocking();
}
