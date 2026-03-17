import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/subscription/domain/subscription_coordinator.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockAuthRepository authRepository;
  late MockUserProfileRepository userProfileRepository;
  late MockSubscriptionRepository subscriptionRepository;
  late StreamController<Session> sessionController;
  late StreamController<UserDto> profileChangesController;

  setUp(() {
    registerTestFallbackValues();
    authRepository = MockAuthRepository();
    userProfileRepository = MockUserProfileRepository();
    subscriptionRepository = MockSubscriptionRepository();
    sessionController = StreamController<Session>.broadcast();
    profileChangesController = StreamController<UserDto>.broadcast();

    when(() => authRepository.sessionStream).thenAnswer((_) => sessionController.stream);
    when(() => userProfileRepository.watchProfileChanges()).thenAnswer((_) => profileChangesController.stream);
    when(
      () => subscriptionRepository.initialize(
        apiKey: any(named: 'apiKey'),
        appUserId: any(named: 'appUserId'),
      ),
    ).thenAnswer((_) async {});
    when(() => subscriptionRepository.logOut()).thenAnswer((_) async {});
  });

  tearDown(() {
    sessionController.close();
    profileChangesController.close();
  });

  group('SubscriptionCoordinator', () {
    test('initializes SDK with fetched user ID on authenticated session', () async {
      final user = makeUserDto().copyWith(id: 'user-123');
      when(() => authRepository.currentSession).thenReturn(makeSession());
      when(
        () => userProfileRepository.fetchProfile(forceRemote: any(named: 'forceRemote')),
      ).thenAnswer((_) async => user);

      final coordinator = SubscriptionCoordinator(
        authRepository: authRepository,
        userProfileRepository: userProfileRepository,
        subscriptionRepository: subscriptionRepository,
        revenueCatApiKey: 'test-key',
      )..attach();

      sessionController.add(makeSession());

      // Allow microtasks to run.
      await Future<void>.delayed(Duration.zero);

      verify(() => subscriptionRepository.initialize(apiKey: 'test-key', appUserId: 'user-123')).called(1);
      coordinator.detach();
    });

    test('waits for profile emission when fetch fails', () async {
      when(() => authRepository.currentSession).thenReturn(makeSession());
      when(
        () => userProfileRepository.fetchProfile(forceRemote: any(named: 'forceRemote')),
      ).thenThrow(Exception('network error'));

      final coordinator = SubscriptionCoordinator(
        authRepository: authRepository,
        userProfileRepository: userProfileRepository,
        subscriptionRepository: subscriptionRepository,
        revenueCatApiKey: 'test-key',
      )..attach();

      sessionController.add(makeSession());
      await Future<void>.delayed(Duration.zero);

      verifyNever(
        () => subscriptionRepository.initialize(
          apiKey: any(named: 'apiKey'),
          appUserId: any(named: 'appUserId'),
        ),
      );

      profileChangesController.add(makeUserDto().copyWith(id: 'user-456'));
      await Future<void>.delayed(Duration.zero);

      verify(() => subscriptionRepository.initialize(apiKey: 'test-key', appUserId: 'user-456')).called(1);
      coordinator.detach();
    });

    test('logs out on unauthenticated session', () async {
      when(() => authRepository.currentSession).thenReturn(const Session.empty());

      final coordinator = SubscriptionCoordinator(
        authRepository: authRepository,
        userProfileRepository: userProfileRepository,
        subscriptionRepository: subscriptionRepository,
        revenueCatApiKey: 'test-key',
      )..attach();

      sessionController.add(const Session.empty());
      await Future<void>.delayed(Duration.zero);

      verify(() => subscriptionRepository.logOut()).called(1);
      coordinator.detach();
    });
  });
}
