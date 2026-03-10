import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate.dart';
import 'package:pauza/src/core/connectivity/model/internet_health_state.dart';
import 'package:pauza/src/core/connectivity/widget/internet_required_body.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('InternetRequiredBody', () {
    testWidgets('shows offline state when gate is unhealthy', (tester) async {
      final gate = FakeInternetHealthGate(isHealthy: false);

      await tester.pumpApp(
        InternetRequiredBody(
          gate: gate,
          offlineTitle: 'Offline',
          offlineMessage: 'No internet',
          offlineRetryButtonLabel: 'Retry',
          child: const Text('Healthy content'),
        ),
      );

      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('No internet'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Healthy content'), findsNothing);
    });

    testWidgets('shows child when gate is healthy', (tester) async {
      final gate = FakeInternetHealthGate(isHealthy: true);

      await tester.pumpApp(
        InternetRequiredBody(
          gate: gate,
          offlineTitle: 'Offline',
          offlineMessage: 'No internet',
          offlineRetryButtonLabel: 'Retry',
          child: const Text('Healthy content'),
        ),
      );

      expect(find.text('Healthy content'), findsOneWidget);
      expect(find.text('Offline'), findsNothing);
    });

    testWidgets('retry triggers forced refresh', (tester) async {
      final gate = FakeInternetHealthGate(isHealthy: false);

      await tester.pumpApp(
        InternetRequiredBody(
          gate: gate,
          offlineTitle: 'Offline',
          offlineMessage: 'No internet',
          offlineRetryButtonLabel: 'Retry',
          child: const Text('Healthy content'),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(gate.lastForce, isTrue);
    });
  });
}

final class FakeInternetHealthGate extends ChangeNotifier implements InternetHealthGate {
  FakeInternetHealthGate({required this.isHealthy});

  @override
  bool isHealthy;

  bool? lastForce;

  @override
  InternetHealthState get state => InternetHealthState.initial();

  @override
  Future<void> refresh({bool force = false}) async {
    lastForce = force;
  }
}
