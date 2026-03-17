import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/modes/common/model/schedule.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_unlock_token.dart';
import 'package:pauza/src/features/streaks/common/model/streak_constants.dart';
import 'package:pauza/src/features/streaks/common/model/streak_snapshot.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';

/// Fixed date used for deterministic test fixtures.
final DateTime _epoch = DateTime.utc(2024);

// ---------------------------------------------------------------------------
// Mode
// ---------------------------------------------------------------------------

Mode makeMode({
  String id = 'mode-1',
  String title = 'Test Mode',
  String textOnScreen = 'Focus',
  String? description,
  int allowedPausesCount = 1,
  Duration? minimumDuration,
  ModeEndingPausingScenario endingPausingScenario = ModeEndingPausingScenario.manual,
  ModeIcon icon = ModeIconCatalog.defaultIcon,
  Schedule? schedule,
  ISet<AppIdentifier> blockedAppIds = const ISetConst<AppIdentifier>(<AppIdentifier>{AppIdentifier('com.example.app')}),
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Mode(
    id: id,
    title: title,
    textOnScreen: textOnScreen,
    description: description,
    allowedPausesCount: allowedPausesCount,
    minimumDuration: minimumDuration,
    endingPausingScenario: endingPausingScenario,
    icon: icon,
    schedule: schedule,
    blockedAppIds: blockedAppIds,
    createdAt: createdAt ?? _epoch,
    updatedAt: updatedAt ?? _epoch,
  );
}

// ---------------------------------------------------------------------------
// RestrictionState
// ---------------------------------------------------------------------------

RestrictionState makeRestrictionState({
  bool isScheduleEnabled = false,
  bool isInScheduleNow = false,
  DateTime? pausedUntil,
  RestrictionMode? activeMode,
  RestrictionModeSource activeModeSource = RestrictionModeSource.none,
  List<RestrictionLifecycleEvent> currentSessionEvents = const <RestrictionLifecycleEvent>[],
}) {
  return RestrictionState(
    isScheduleEnabled: isScheduleEnabled,
    isInScheduleNow: isInScheduleNow,
    pausedUntil: pausedUntil,
    activeMode: activeMode,
    activeModeSource: activeModeSource,
    currentSessionEvents: currentSessionEvents,
  );
}

// ---------------------------------------------------------------------------
// StreakSnapshot
// ---------------------------------------------------------------------------

StreakSnapshot makeStreakSnapshot({
  DateTime? asOfLocal,
  Duration? targetDurationPerDay,
  Duration todayEffectiveDuration = Duration.zero,
  CurrentStreakDays currentStreakDays = const CurrentStreakDays.zero(),
  BestStreakDays bestStreakDays = const BestStreakDays.zero(),
}) {
  return StreakSnapshot(
    asOfLocal: asOfLocal ?? _epoch,
    targetDurationPerDay: targetDurationPerDay ?? StreakConstants.targetDurationPerDay,
    todayEffectiveDuration: todayEffectiveDuration,
    currentStreakDays: currentStreakDays,
    bestStreakDays: bestStreakDays,
  );
}

// ---------------------------------------------------------------------------
// QrLinkedCode
// ---------------------------------------------------------------------------

QrLinkedCode makeQrLinkedCode({
  String id = 'qr-1',
  QrUnlockToken? scanValue,
  String name = 'Test QR Code',
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return QrLinkedCode(
    id: id,
    scanValue: scanValue ?? QrUnlockToken.parse('pauza:qr:v1:123e4567-e89b-42d3-a456-426614174000'),
    name: name,
    createdAt: createdAt ?? _epoch,
    updatedAt: updatedAt ?? _epoch,
  );
}

// ---------------------------------------------------------------------------
// NfcLinkedChip
// ---------------------------------------------------------------------------

NfcLinkedChip makeNfcLinkedChip({
  String id = 'nfc-1',
  String chipIdentifier = '04aabbccdd',
  String name = 'Test NFC Chip',
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return NfcLinkedChip(
    id: id,
    chipIdentifier: chipIdentifier,
    name: name,
    createdAt: createdAt ?? _epoch,
    updatedAt: updatedAt ?? _epoch,
  );
}

// ---------------------------------------------------------------------------
// NfcCardDto
// ---------------------------------------------------------------------------

NfcCardDto makeNfcCardDto({
  String id = 'card-1',
  DateTime? detectedAt,
  NfcChipIdentifier? uidHex,
  IList<NfcTagTech> techTypes = const IListConst<NfcTagTech>(<NfcTagTech>[NfcTagTech.nfcA]),
  bool isNdefFormatted = false,
  IList<NfcNdefRecordDto> ndefRecords = const IListConst<NfcNdefRecordDto>(<NfcNdefRecordDto>[]),
  IMap<String, Object?> rawSnapshot = const IMapConst<String, Object?>(<String, Object?>{}),
}) {
  return NfcCardDto(
    id: id,
    detectedAt: detectedAt ?? _epoch,
    uidHex: uidHex ?? NfcChipIdentifier.parse('04aabbccdd'),
    techTypes: techTypes,
    isNdefFormatted: isNdefFormatted,
    ndefRecords: ndefRecords,
    rawSnapshot: rawSnapshot,
  );
}

// ---------------------------------------------------------------------------
// UserDto
// ---------------------------------------------------------------------------

UserDto makeUserDto({String? profilePicture, String username = 'testuser', String name = 'Test User'}) {
  return UserDto(profilePicture: profilePicture, username: username, name: name);
}

// ---------------------------------------------------------------------------
// Session
// ---------------------------------------------------------------------------

Session makeSession({String accessToken = 'test-access-token', String refreshToken = 'test-refresh-token'}) {
  return Session(accessToken: accessToken, refreshToken: refreshToken);
}

// ---------------------------------------------------------------------------
// ModeUpsertDTO
// ---------------------------------------------------------------------------

ModeUpsertDTO makeModeUpsertDto({
  String title = 'Test Mode',
  String textOnScreen = 'Focus',
  String? description,
  int allowedPausesCount = 1,
  Duration? minimumDuration,
  ModeEndingPausingScenario endingPausingScenario = ModeEndingPausingScenario.manual,
  ModeIcon icon = ModeIconCatalog.defaultIcon,
  Schedule? schedule,
  ISet<AppIdentifier> blockedAppIds = const ISetConst<AppIdentifier>(<AppIdentifier>{AppIdentifier('com.example.app')}),
}) {
  return ModeUpsertDTO(
    title: title,
    textOnScreen: textOnScreen,
    description: description,
    allowedPausesCount: allowedPausesCount,
    minimumDuration: minimumDuration,
    endingPausingScenario: endingPausingScenario,
    icon: icon,
    schedule: schedule,
    blockedAppIds: blockedAppIds,
  );
}
