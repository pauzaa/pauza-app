// import 'dart:async';

// import 'package:flutter/widgets.dart';
// import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
// import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';

// final class NfcCapabilityController extends ChangeNotifier with WidgetsBindingObserver {
//   NfcCapabilityController({
//     required NfcRepository repository,
//     this.minRefreshInterval = const Duration(seconds: 1),
//   }) : _repository = repository {
//     WidgetsBinding.instance.addObserver(this);
//     unawaited(refresh(force: true));
//   }

//   final NfcRepository _repository;
//   final Duration minRefreshInterval;

//   NfcChipAvailability _availability = NfcChipAvailability.notSupported;
//   DateTime? _lastRefreshAt;
//   Future<void>? _inFlightRefresh;

//   NfcChipAvailability get availability => _availability;
//   bool get canOpenSystemSettingsForNfc => _repository.canOpenSystemSettingsForNfc;
//   NfcChipAvailability get guidance => _availability;

//   Future<bool> openSystemSettingsForNfc() async {
//     return _repository.openSystemSettingsForNfc();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       unawaited(refresh());
//     }
//   }

//   Future<void> refresh({bool force = false}) async {
//     final inFlightRefresh = _inFlightRefresh;
//     if (inFlightRefresh != null) {
//       return inFlightRefresh;
//     }

//     if (!force) {
//       if (_lastRefreshAt case final lastRefreshAt?
//           when DateTime.now().difference(lastRefreshAt) < minRefreshInterval) {
//         return;
//       }
//     }

//     final refreshFuture = _refreshInternal();
//     _inFlightRefresh = refreshFuture;

//     try {
//       await refreshFuture;
//     } finally {
//       if (identical(_inFlightRefresh, refreshFuture)) {
//         _inFlightRefresh = null;
//       }
//     }
//   }

//   Future<void> _refreshInternal() async {
//     final checkedAt = DateTime.now();

//     try {
//       final nextAvailability = await _repository.getAvailability();
//       if (nextAvailability != _availability) {
//         _availability = nextAvailability;
//         notifyListeners();
//       }
//     } on Object {
//       if (_availability != NfcChipAvailability.notSupported) {
//         _availability = NfcChipAvailability.notSupported;
//         notifyListeners();
//       }
//     } finally {
//       _lastRefreshAt = checkedAt;
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
// }
