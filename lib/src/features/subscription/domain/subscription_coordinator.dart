import 'dart:async';
import 'dart:developer';

import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';
import 'package:pauza/src/features/subscription/data/subscription_repository.dart';

/// Coordinates RevenueCat SDK lifecycle with the auth session.
///
/// Mirrors [DeviceTokenCoordinator] pattern: listens to [AuthRepository.sessionStream],
/// initialises RevenueCat on sign-in (using the real user ID), and logs out on sign-out.
final class SubscriptionCoordinator {
  SubscriptionCoordinator({
    required AuthRepository authRepository,
    required UserProfileRepository userProfileRepository,
    required SubscriptionRepository subscriptionRepository,
    required String revenueCatApiKey,
  }) : _authRepository = authRepository,
       _userProfileRepository = userProfileRepository,
       _subscriptionRepository = subscriptionRepository,
       _revenueCatApiKey = revenueCatApiKey;

  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;
  final SubscriptionRepository _subscriptionRepository;
  final String _revenueCatApiKey;

  static const _backendSyncDelay = Duration(seconds: 5);

  bool _isAttached = false;
  StreamSubscription<void>? _sessionSubscription;
  StreamSubscription<void>? _profileSubscription;
  StreamSubscription<void>? _subscriptionChangesSubscription;
  Timer? _backendSyncTimer;

  void attach() {
    if (_isAttached) return;

    _sessionSubscription = _authRepository.sessionStream.listen((_) => _onSessionChanged());
    _isAttached = true;
  }

  void detach() {
    if (!_isAttached) return;

    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _cancelProfileSubscription();
    _cancelSubscriptionChanges();
    _isAttached = false;
  }

  // ---------------------------------------------------------------------------

  void _onSessionChanged() {
    final isAuthenticated = _authRepository.currentSession.isAuthenticated;

    if (isAuthenticated) {
      unawaited(_initializeWithUserId());
    } else {
      _cancelProfileSubscription();
      _cancelSubscriptionChanges();
      unawaited(_subscriptionRepository.logOut());
    }
  }

  Future<void> _initializeWithUserId() async {
    _cancelProfileSubscription();
    _profileSubscription = _userProfileRepository.watchProfileChanges().listen((user) async {
      if (!_isAttached) return;
      if (user.id.isNotEmpty) {
        _cancelProfileSubscription();
        await _initializeSdk(user.id);
      }
    });

    try {
      if (!_isAttached) return;
      final user = await _userProfileRepository.fetchProfile();
      if (!_isAttached) return;
      if (user.id.isNotEmpty) {
        _cancelProfileSubscription();
        await _initializeSdk(user.id);
      }
    } on Object catch (e) {
      log('SubscriptionCoordinator: profile fetch failed: $e', name: 'subscription');
    }
  }

  Future<void> _initializeSdk(String userId) async {
    try {
      await _subscriptionRepository.initialize(apiKey: _revenueCatApiKey, appUserId: userId);
      if (_subscriptionChangesSubscription != null) return;
      _listenToSubscriptionChanges();
    } on Object catch (e) {
      log('SubscriptionCoordinator: SDK init failed: $e', name: 'subscription');
    }
  }

  void _listenToSubscriptionChanges() {
    _cancelSubscriptionChanges();
    _subscriptionChangesSubscription = _subscriptionRepository.watchSubscriptionChanges().listen(
      (subscription) {
        if (!_isAttached) return;
        _userProfileRepository.applyOptimisticSubscription(subscription);
        _scheduleBackendSync();
      },
      onError: (Object e) {
        log('SubscriptionCoordinator: subscription change error: $e', name: 'subscription');
      },
    );
  }

  void _scheduleBackendSync() {
    _backendSyncTimer?.cancel();
    _backendSyncTimer = Timer(_backendSyncDelay, () async {
      if (!_isAttached) return;
      try {
        await _userProfileRepository.fetchProfile(forceRemote: true);
      } on Object catch (e) {
        log('SubscriptionCoordinator: backend sync failed: $e', name: 'subscription');
      }
    });
  }

  void _cancelProfileSubscription() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
  }

  void _cancelSubscriptionChanges() {
    _subscriptionChangesSubscription?.cancel();
    _subscriptionChangesSubscription = null;
    _backendSyncTimer?.cancel();
    _backendSyncTimer = null;
  }
}
