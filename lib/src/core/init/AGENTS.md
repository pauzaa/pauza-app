# Init & Dependencies
> See [AGENTS.md](/AGENTS.md) for project-wide rules and [lib/src/core/AGENTS.md](lib/src/core/AGENTS.md) for core layering.

## OVERVIEW

`init/` owns app startup and dependency wiring. `PauzaDependencies` (AppFuse `AppFuseInitialization`) runs ordered steps: local DB → API client → auth → sync → connectivity → permissions → feature repositories. `PauzaConfig` loads JSON config from `config/` for API URL and internet probe.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| DI, startup steps | `pauza_dependencies.dart` | Steps: local DB, API client, auth, sync, internet gate, package info, permissions, user profile, friends, leaderboard, managers, restriction lifecycle, streaks, blocking stats, background sync |
| Config loading | `config.dart` | `PauzaConfig`, `ProdConfig`, `TestConfig`; `apiBaseUrl`, `internetProbeUrl`, `appName` |
| Resolve API / probe URL | `pauza_dependencies.dart` | `_resolveInternetProbeUri()` prefers config over default Google probe |

## CONVENTIONS

- Steps depend on `PauzaConfig`; config is loaded from assets via AppFuse before init.
- Step order matters: DB and API client before auth; auth before sync; sync before features that use it.
- Access dependencies via `PauzaDependencies.of(BuildContext context)` after AppFuse scope is ready.
- `PauzaDependencies` disposes gates and repositories in `PauzaApp.dispose()`.

## ANTI-PATTERNS

- Do not add init steps that depend on steps declared later; respect ordering.
- Do not parse config outside `config.dart`; use `PauzaConfig` extensions.
- Do not forget to dispose `internetHealthGate`, `authGate`, `authRepository`, `permissionGate` in app dispose.
