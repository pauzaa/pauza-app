import 'package:pauza/src/core/connectivity/domain/internet_health_gate.dart';

abstract interface class InternetRequiredGuard {
  bool get isHealthy;

  Future<bool> canProceed({bool forceRefresh = true});
}

final class InternetRequiredGuardImpl implements InternetRequiredGuard {
  InternetRequiredGuardImpl({required InternetHealthGate internetHealthGate})
    : _internetHealthGate = internetHealthGate;

  final InternetHealthGate _internetHealthGate;

  @override
  bool get isHealthy => _internetHealthGate.isHealthy;

  @override
  Future<bool> canProceed({bool forceRefresh = true}) async {
    await _internetHealthGate.refresh(force: forceRefresh);
    return _internetHealthGate.isHealthy;
  }
}
