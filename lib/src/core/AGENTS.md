# Core – Shared Infrastructure
> See [/AGENTS.md](/AGENTS.md) for project-wide rules and [lib/AGENTS.md](../../AGENTS.md) for lib layout.

## OVERVIEW

`lib/src/core/` holds shared infrastructure: API client, local database, routing, init/DI, connectivity, localization, and common UI. These modules are consumed by features; they do not depend on feature code.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| HTTP / REST API calls | `api_client/` | `ApiClient`, `ApiClientRequest`, auth/retry/logger middleware |
| Auth token or retry behavior | `api_client/middleware/` | `auth_mw.dart`, `retry_mw.dart` |
| Internet / connectivity | `connectivity/` | `InternetHealthGate`, `InternetRequiredGuard`, `InternetRequiredBody` |
| Offline UI | `connectivity/`, `common_ui/` | `internet_required_body.dart`, `no_internet_state.dart` |
| DI and startup wiring | `init/` | `pauza_dependencies.dart`, `config.dart` |
| Local SQLite DB | `local_database/` | `LocalDatabase`, `SqfliteLocalDatabase`, `PauzaLocalDatabaseSchemaV1` |
| DB schema / migrations | `local_database/` | `local_database_schema.dart`, `pauza_local_database_schema_v1.dart` |
| Navigation / routing | `routing/` | `pauza_routes.dart`, `pauza_router.dart`, `pauza_router_guards.dart` |
| Route definitions | `routing/` | `pauza_routes.dart` (Routable enum) |
| Auth / permission guards | `routing/` | `pauza_router_guards.dart` |
| Localization | `localization/` | `l10n.dart`, `gen/` (generated) |
| Error / toast / splash UI | `common_ui/` | `pauza_error_widget.dart`, `pauza_toast.dart`, `pauza_splash_screen.dart` |
| App errors, validation | `common/` | `pauza_app_error.dart`, `validation.dart` |
| Platform checks | `common/` | `pauza_platform.dart` |
| DateTime / Duration helpers | `common/` | `extensions.dart` |

## CONVENTIONS

- API client middleware order: Logger → Auth → Retry (in `pauza_dependencies.dart`).
- `LocalDatabase` is used by repositories; schema versioning via `LocalDatabaseSchema.onUpgrade`.
- Routing uses Helm `Routable` enum; guards for auth and permissions.
- Config: JSON assets in `config/`; `ProdConfig`, `TestConfig` map to `Assets.config.*`.

## ANTI-PATTERNS

- Do not open DB transactions or make HTTP calls outside repository/data-source layer.
- Do not parse env or load config outside `init/` and AppFuse config.
- Do not bypass `pauza_dependencies.dart` when wiring new dependencies.

## RELATED DOCS

- [lib/src/core/init/AGENTS.md](init/AGENTS.md)
- [lib/src/core/api_client/AGENTS.md](api_client/AGENTS.md)
- [lib/src/core/local_database/AGENTS.md](local_database/AGENTS.md)
- [lib/src/core/routing/AGENTS.md](routing/AGENTS.md)
