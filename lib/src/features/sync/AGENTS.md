# Sync Feature
> See [lib/src/features/AGENTS.md](../AGENTS.md) for feature layout and [/AGENTS.md](/AGENTS.md) for project-wide rules.

## OVERVIEW

`sync/` coordinates bidirectional sync between local SQLite and pauza-server. `SyncRepository` uses `SyncLocalDataSource` and `SyncRemoteDataSource`; row DTOs live in `common/model/rows/`. Sync tables include modes, NFC chips, QR codes, restriction lifecycle, streaks. Features call `notifyExternalChange` when local data changes.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Sync orchestration | `data/` | `SyncRepository`, `SyncCoordinator` |
| Local table access | `data/sync_local_data_source.dart` | Read/write sync tables, cursors, deletion log |
| Remote API | `data/sync_remote_data_source.dart` | Sync endpoint calls via `ApiClient` |
| Row DTOs | `common/model/rows/` | `SyncModeRows`, etc.; `fromJson` / `toJson` for each table |
| Sync table enum | `common/model/` | `SyncTable` defines all syncable tables |

## CONVENTIONS

- Each sync table has corresponding row DTOs; mapping in factory constructors.
- `SyncLocalDataSource` owns local DB access; repositories use it via `notifyExternalChange`.
- Sync runs on connectivity and auth; `SyncRepository` coordinates pull/push.
- Cursors and deletion log track server state for incremental sync.

## ANTI-PATTERNS

- Do not put sync logic in feature repositories; use `SyncRepository` and `notifyExternalChange`.
- Do not bypass `SyncLocalDataSource` when mutating syncable tables.
- Do not forget to clear sync tables on sign-out (handled in auth `onSignOutCleanup`).
