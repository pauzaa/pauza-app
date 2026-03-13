# Features – Feature Modules
> See [/AGENTS.md](/AGENTS.md) for project-wide rules and [lib/AGENTS.md](../../AGENTS.md) for lib layout.

## OVERVIEW

`lib/src/features/` holds feature modules in a recursive layout. Each feature typically has `bloc/`, `data/`, `model/`, `widget/` (and subfeatures like `add_edit/`, `list/`). Dependencies flow `widget → bloc → repository → data_source`; features consume `core/` and optionally other features.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Auth (login, OTP, session) | `auth/` | `AuthBloc`, `AuthRepository`, `AuthScreen`, `OtpScreen` |
| Blocking / pause / resume / start session | `home/` | `BlockingBloc`, `PauzaBlockingRepository`, `HomeScreen` |
| Modes CRUD, edit, list, pick | `modes/` | `ModesRepository`, `ModeEditorBloc`, `ModesListBloc`, `ModePickerSheet` |
| App selection for modes | `modes/select_apps/` | `InstalledAppsBloc`, `PauzaScreenTimeInstalledAppsRepository` |
| Sync (local ↔ remote) | `sync/` | `SyncRepository`, `SyncLocalDataSource`, `SyncRemoteDataSource`, `SyncCoordinator` |
| Restriction lifecycle, background worker | `restriction_lifecycle/` | `RestrictionLifecycleRepository`, plugin client, background scheduler |
| Streaks, aggregates | `streaks/` | `StreaksRepository`, `StreakSnapshot`, `StreakTypes` |
| Blocking stats | `stats/blocking_stats/` | `StatsBlockingRepository`, `StatsBlockingBloc` |
| Usage stats | `stats/usage_stats/` | `StatsUsageRepository`, `StatsUsageBloc` |
| Profile, edit, avatar | `profile/` | `ProfileScreen`, `ProfileEditScreen`, `UserProfileRepository`, `CurrentUserBloc` |
| Friends | `friends/` | `FriendsRepository`, `FriendsRemoteDataSource` |
| Leaderboard | `leaderboard/` | `LeaderboardScreen`, `LeaderboardRepository` |
| NFC chips, link/unlink | `nfc_chip_config/` | `NfcChipConfScreen`, `NfcLinkedChipsRepository` |
| QR codes, link/unlink | `qr_code_config/` | `QrCodeConfScreen`, `QrLinkedCodesRepository` |
| NFC scan sheet | `nfc/` | `NfcRepository`, `NfcChipScanSheet` |
| QR scan sheet | `qr_code/` | `QrCodeScanView`, `QrCodeScanSheet` |
| Settings, preferences | `settings/` | `SettingsScreen`, `UserPreferencesBloc` |
| Permissions | `permissions/` | `PermissionsScreen`, `PauzaPermissionGate` |
| AI (addiction check, focus schedule) | `ai/` | `AiRepository`, `AiRemoteDataSource` |

## CONVENTIONS

- Feature layout: `data/` (repository, data sources), `model/` (DTOs, domain models), `bloc/` (events, states, bloc), `widget/` (screens, UI).
- Repository: abstract interface in `data/`, `*Impl` concrete; data sources for remote/local.
- BLoC: state extends `Equatable`; handle errors in try-catch; emit error states.
- Cross-feature deps: `sync` depends on modes, nfc_chip_config, qr_code_config, restriction_lifecycle, streaks; `home` uses modes, nfc, qr.

## ANTI-PATTERNS

- Do not put SQL or HTTP logic in BLoC or widget layer.
- Do not duplicate repository interfaces; use abstract interface + single impl.
- Do not introduce circular feature dependencies.

## RELATED DOCS

- [lib/src/features/auth/AGENTS.md](auth/AGENTS.md)
- [lib/src/features/modes/AGENTS.md](modes/AGENTS.md)
- [lib/src/features/sync/AGENTS.md](sync/AGENTS.md)
- [lib/src/features/home/AGENTS.md](home/AGENTS.md)
