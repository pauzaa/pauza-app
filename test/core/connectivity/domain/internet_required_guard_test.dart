import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('InternetRequiredGuardImpl', () {
    test('canProceed(forceRefresh: true) refreshes with force and returns current health', () async {
      final gate = MockInternetHealthGate();
      when(() => gate.refresh(force: true)).thenAnswer((_) async {});
      when(() => gate.isHealthy).thenReturn(true);

      final guard = InternetRequiredGuardImpl(internetHealthGate: gate);

      final result = await guard.canProceed();

      expect(result, isTrue);
      verify(() => gate.refresh(force: true)).called(1);
    });

    test('canProceed(forceRefresh: false) refreshes without force and returns current health', () async {
      final gate = MockInternetHealthGate();
      when(() => gate.refresh(force: any(named: 'force'))).thenAnswer((_) async {});
      when(() => gate.isHealthy).thenReturn(false);

      final guard = InternetRequiredGuardImpl(internetHealthGate: gate);

      final result = await guard.canProceed(forceRefresh: false);

      expect(result, isFalse);
      verify(() => gate.refresh()).called(1);
    });
  });
}
