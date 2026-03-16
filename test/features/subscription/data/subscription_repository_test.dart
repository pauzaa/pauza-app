import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pauza/src/features/subscription/data/subscription_repository.dart';
import 'package:pauza/src/features/subscription/model/subscription_failure.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockPurchasesDataSource dataSource;
  late SubscriptionRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakePackage());
  });

  setUp(() {
    dataSource = MockPurchasesDataSource();
    repository = SubscriptionRepositoryImpl(dataSource: dataSource, entitlementId: 'premium');
  });

  group('initialize', () {
    test('delegates to data source configure', () async {
      when(
        () => dataSource.configure(
          apiKey: any(named: 'apiKey'),
          appUserId: any(named: 'appUserId'),
        ),
      ).thenAnswer((_) async {});

      await repository.initialize(apiKey: 'key', appUserId: 'user-1');

      verify(() => dataSource.configure(apiKey: 'key', appUserId: 'user-1')).called(1);
    });

    test('throws SubscriptionUnknownError on failure', () async {
      when(
        () => dataSource.configure(
          apiKey: any(named: 'apiKey'),
          appUserId: any(named: 'appUserId'),
        ),
      ).thenThrow(Exception('boom'));

      expect(() => repository.initialize(apiKey: 'key', appUserId: 'user-1'), throwsA(isA<SubscriptionUnknownError>()));
    });
  });

  group('getOffering', () {
    test('throws SubscriptionNotConfiguredError when not configured', () {
      when(() => dataSource.isConfigured).thenReturn(false);

      expect(() => repository.getOffering(), throwsA(isA<SubscriptionNotConfiguredError>()));
    });
  });

  group('purchase', () {
    test('throws SubscriptionNotConfiguredError when not configured', () {
      when(() => dataSource.isConfigured).thenReturn(false);
      final package = _FakePackage();

      expect(() => repository.purchase(package), throwsA(isA<SubscriptionNotConfiguredError>()));
    });

    test('throws SubscriptionPurchaseCancelledError on user cancellation', () {
      when(() => dataSource.isConfigured).thenReturn(true);
      when(() => dataSource.purchasePackage(any())).thenThrow(
        PlatformException(
          code: '1',
          message: 'Purchase cancelled',
          details: {'readable_error_code': 'PURCHASE_CANCELLED'},
        ),
      );
      final package = _FakePackage();

      expect(() => repository.purchase(package), throwsA(isA<SubscriptionPurchaseCancelledError>()));
    });
  });

  group('logOut', () {
    test('delegates to data source logOut', () async {
      when(() => dataSource.logOut()).thenAnswer((_) async {});

      await repository.logOut();

      verify(() => dataSource.logOut()).called(1);
    });

    test('swallows errors from data source', () async {
      when(() => dataSource.logOut()).thenThrow(Exception('network'));

      await repository.logOut();
    });
  });

  group('restorePurchases', () {
    test('throws SubscriptionNotConfiguredError when not configured', () {
      when(() => dataSource.isConfigured).thenReturn(false);

      expect(() => repository.restorePurchases(), throwsA(isA<SubscriptionNotConfiguredError>()));
    });
  });
}

class _FakePackage extends Fake implements Package {}
