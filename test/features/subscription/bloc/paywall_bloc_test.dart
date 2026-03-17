import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/subscription/bloc/paywall_bloc.dart';
import 'package:pauza/src/features/subscription/model/subscription_failure.dart';

import '../../../helpers/helpers.dart';

class _FakePackage extends Fake implements Package {
  @override
  String get identifier => 'test-package';

  @override
  StoreProduct get storeProduct => _FakeStoreProduct();
}

class _FakeStoreProduct extends Fake implements StoreProduct {
  @override
  String get title => 'Test';

  @override
  String get priceString => r'$9.99';
}

class _FakeOffering extends Fake implements Offering {
  @override
  List<Package> get availablePackages => <Package>[_FakePackage()];
}

void main() {
  late MockSubscriptionRepository subscriptionRepository;
  late MockAuthRepository authRepository;
  late MockUserProfileRepository userProfileRepository;
  late CurrentUserBloc currentUserBloc;
  late StreamController<Session> sessionController;

  setUp(() {
    registerTestFallbackValues();
    registerFallbackValue(_FakePackage());
    subscriptionRepository = MockSubscriptionRepository();
    authRepository = MockAuthRepository();
    userProfileRepository = MockUserProfileRepository();
    sessionController = StreamController<Session>.broadcast();

    when(() => authRepository.sessionStream).thenAnswer((_) => sessionController.stream);
    when(() => authRepository.currentSession).thenReturn(const Session.empty());
    when(() => userProfileRepository.watchProfileChanges()).thenAnswer((_) => const Stream<UserDto>.empty());

    currentUserBloc = CurrentUserBloc(
      authRepository: authRepository,
      userProfileRepository: userProfileRepository,
    );
  });

  tearDown(() async {
    await currentUserBloc.close();
    await sessionController.close();
  });

  group('PaywallBloc', () {
    blocTest<PaywallBloc, PaywallState>(
      'emits loading then packages on PaywallStarted',
      setUp: () {
        when(() => subscriptionRepository.getOffering()).thenAnswer((_) async => _FakeOffering());
      },
      build: () => PaywallBloc(subscriptionRepository: subscriptionRepository, currentUserBloc: currentUserBloc),
      act: (bloc) => bloc.add(const PaywallStarted()),
      expect: () => <Object>[
        const PaywallState(isLoadingOfferings: true),
        isA<PaywallState>()
            .having((s) => s.packages.length, 'packages.length', 1)
            .having((s) => s.isLoadingOfferings, 'isLoadingOfferings', false),
      ],
    );

    blocTest<PaywallBloc, PaywallState>(
      'emits error on PaywallStarted failure',
      setUp: () {
        when(() => subscriptionRepository.getOffering()).thenThrow(const SubscriptionNotConfiguredError());
      },
      build: () => PaywallBloc(subscriptionRepository: subscriptionRepository, currentUserBloc: currentUserBloc),
      act: (bloc) => bloc.add(const PaywallStarted()),
      expect: () => <Object>[
        const PaywallState(isLoadingOfferings: true),
        isA<PaywallState>()
            .having((s) => s.isLoadingOfferings, 'isLoadingOfferings', false)
            .having((s) => s.error, 'error', isA<SubscriptionNotConfiguredError>()),
      ],
    );

    blocTest<PaywallBloc, PaywallState>(
      'emits purchasing then success on purchase',
      setUp: () {
        when(() => subscriptionRepository.purchase(any())).thenAnswer((_) async {});
      },
      build: () => PaywallBloc(subscriptionRepository: subscriptionRepository, currentUserBloc: currentUserBloc),
      act: (bloc) => bloc.add(PaywallPurchaseRequested(package: _FakePackage())),
      expect: () => <PaywallState>[const PaywallState(isPurchasing: true), const PaywallState(purchaseSuccess: true)],
    );

    blocTest<PaywallBloc, PaywallState>(
      'emits non-error state on purchase cancellation',
      setUp: () {
        when(() => subscriptionRepository.purchase(any())).thenThrow(const SubscriptionPurchaseCancelledError());
      },
      build: () => PaywallBloc(subscriptionRepository: subscriptionRepository, currentUserBloc: currentUserBloc),
      act: (bloc) => bloc.add(PaywallPurchaseRequested(package: _FakePackage())),
      expect: () => <PaywallState>[const PaywallState(isPurchasing: true), const PaywallState()],
    );

    blocTest<PaywallBloc, PaywallState>(
      'emits purchasing then success on restore',
      setUp: () {
        when(() => subscriptionRepository.restorePurchases()).thenAnswer((_) async {});
      },
      build: () => PaywallBloc(subscriptionRepository: subscriptionRepository, currentUserBloc: currentUserBloc),
      act: (bloc) => bloc.add(const PaywallRestoreRequested()),
      expect: () => <PaywallState>[const PaywallState(isPurchasing: true), const PaywallState(purchaseSuccess: true)],
    );
  });
}
