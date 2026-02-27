import 'package:flutter/widgets.dart';
import 'package:pauza/src/core/connectivity/model/internet_health_state.dart';

abstract interface class InternetHealthGate implements Listenable {
  InternetHealthState get state;

  bool get isHealthy;

  Future<void> refresh({bool force = false});

  void dispose();
}
