import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
import 'package:pauza/src/core/connectivity/model/internet_health_state.dart';

void main() {
  group('InternetRequiredGuardImpl', () {
    test('canProceed(forceRefresh: true) refreshes with force and returns current health', () async {
      final gate = _FakeInternetHealthGate(isHealthy: true);
      final guard = InternetRequiredGuardImpl(internetHealthGate: gate);

      final result = await guard.canProceed();

      expect(result, isTrue);
      expect(gate.lastForce, isTrue);
    });

    test('canProceed(forceRefresh: false) refreshes without force and returns current health', () async {
      final gate = _FakeInternetHealthGate(isHealthy: false);
      final guard = InternetRequiredGuardImpl(internetHealthGate: gate);

      final result = await guard.canProceed(forceRefresh: false);

      expect(result, isFalse);
      expect(gate.lastForce, isFalse);
    });
  });
}

final class _FakeInternetHealthGate extends ChangeNotifier implements InternetHealthGate {
  _FakeInternetHealthGate({required this.isHealthy});

  @override
  final bool isHealthy;

  bool? lastForce;

  @override
  InternetHealthState get state => InternetHealthState.initial();

  @override
  Future<void> refresh({bool force = false}) async {
    lastForce = force;
  }
}
