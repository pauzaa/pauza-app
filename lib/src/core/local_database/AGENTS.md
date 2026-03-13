# Local Database
> See [AGENTS.md](/AGENTS.md) for project-wide rules and [lib/src/core/AGENTS.md](lib/src/core/AGENTS.md) for core layering.

## OVERVIEW

`local_database/` provides the SQLite abstraction used for offline-first storage. `LocalDatabase` interface is implemented by `SqfliteLocalDatabase`. Schema and migrations live in `PauzaLocalDatabaseSchemaV1`; tables include modes, schedules, restriction lifecycle, NFC/QR, streaks, and sync cursors.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Database interface | `local_database_service.dart` | `LocalDatabase`: `open`, `close`, `read`, `write`, `transaction` |
| Config and version | `local_database_config.dart` | `LocalDatabaseConfig.pauza` (version 5) |
| Schema, migrations | `pauza_local_database_schema_v1.dart` | `onConfigure`, `onCreate`, `onUpgrade`; modes, schedules, restriction_lifecycle_events, nfc_chips, qr_codes, streaks, sync cursors |
| Sqflite implementation | `sqflite_local_database.dart` | `SqfliteLocalDatabase` |
| Barrel export | `local_database.dart` | Re-exports all types |

## CONVENTIONS

- Repositories and data sources use `LocalDatabase`; no repository pattern in core itself.
- Schema versioning via `LocalDatabaseSchema`; migrations in `onUpgrade`.
- Use `database.transaction()` for multi-step writes; keep reads outside transactions when possible.
- Consume `LocalDatabase` from `PauzaDependencies.of(context).localDatabase`; do not open a second instance.

## ANTI-PATTERNS

- Do not put SQL strings in widgets or BLoCs; keep them in repositories or data sources.
- Do not bypass migrations; schema changes go through `onUpgrade` with version bumps.
- Do not open the database outside `PauzaDependencies`; a single instance is shared.
- Do not use unbounded or non-parameterized SQL.
