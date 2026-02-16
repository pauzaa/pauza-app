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
    : _authRepository = authRepository,
      _session = authRepository.currentSession {
    _subscription = _authRepository.sessionStream.listen(_onSessionChanged);
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<Session> _subscription;

  Session _session;

  @override
  Session get session => _session;

  @override
  bool get isAuthenticated => _session.isAuthenticated;

  void _onSessionChanged(Session session) {
    if (_session == session) {
      return;
    }

    _session = session;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
