# Home Feature
> See [lib/src/features/AGENTS.md](../AGENTS.md) for feature layout and [/AGENTS.md](/AGENTS.md) for project-wide rules.

## OVERVIEW

`home/` is the main dashboard: mode selection, session start/pause/resume, blocking UI. Uses `BlockingBloc`, `PauzaBlockingRepository`, and integrates with modes, NFC, QR for unlock flows. Depends on `ModesRepository`, `NfcLinkedChipsRepository`, `QrLinkedCodesRepository`, and restriction lifecycle.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Home screen | `widget/` | `HomeScreen`, `HomeContent` |
| Blocking state machine | `bloc/` | `BlockingBloc`; start, pause, resume, end session |
| Blocking repository | `data/` | `PauzaBlockingRepository`; coordinates with restriction lifecycle |
| Session button, mode picker | `widget/` | `HomeSessionButton`; uses `ModePickerSheet`, `NfcChipScanSheet`, `QrCodeScanSheet` |
| Mode ending scenarios | `model/` | `ModeEndingPausingScenario` (from modes) |

## CONVENTIONS

- Session lifecycle: start → pause/resume → end; `PauzaBlockingRepository` delegates to restriction lifecycle plugin.
- Unlock: NFC chip, QR code, or PIN; sheets from `nfc` and `qr_code` features.
- `BlockingBloc` listens to mode changes; uses `ModesRepository` for mode data.
- Home is the primary entry after auth; navigation via `DashboardTabsShell`.

## ANTI-PATTERNS

- Do not put restriction plugin calls in widget layer; use `PauzaBlockingRepository`.
- Do not bypass mode picker when starting a session; user must select mode.
- Do not forget to handle offline when starting/pausing (connectivity may be required for sync).
