import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';

abstract interface class PauzaAuthGate implements Listenable {
  Session get session;

  bool get isAuthenticated;

  void dispose();
}

final class PauzaAuthGateNotifier extends ChangeNotifier implements PauzaAuthGate {
  PauzaAuthGateNotifier({required AuthRepository authRepository})
    : _authRepository = authRepository {
    _subscription = _authRepository.sessionStream.listen(_onSessionChanged);
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<Session> _subscription;

  @override
  Session get session => _authRepository.currentSession;

  @override
  bool get isAuthenticated => _authRepository.currentSession.isAuthenticated;

  void _onSessionChanged(Session session) {
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
