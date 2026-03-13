# Lib – Application Source
> See [AGENTS.md](/AGENTS.md) for project-wide commands, conventions, and structure.

## OVERVIEW

`lib/` contains all application source code. Entry point is `main.dart`; `src/` holds `app/` (shell, root scope), `core/` (API, DB, routing, init, connectivity), and `features/` (feature modules). Layering is `widget → bloc → repository → data_source`.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| App entry, theme, locale | `lib/src/app/` | `pauza_app.dart`, `root_scope.dart` |
| DI and startup | `lib/src/core/init/` | `pauza_dependencies.dart` |
| HTTP client | `lib/src/core/api_client/` | `ApiClient` + auth/retry/logger middleware |
| Local DB | `lib/src/core/local_database/` | Schema, migrations |
| Routing | `lib/src/core/routing/` | Helm routes, guards |
| Connectivity | `lib/src/core/connectivity/` | Internet health gate, guards |
| Auth | `lib/src/features/auth/` | Bloc, repository, screens |
| Home, blocking | `lib/src/features/home/` | BlockingBloc, session UI |
| Modes | `lib/src/features/modes/` | CRUD, editor, list |
| Sync | `lib/src/features/sync/` | Local ↔ remote |

## CONVENTIONS

- Use `package:pauza/...` imports; group SDK, third-party, then package.
- One widget per file; avoid `_buildItem()` helpers.
- Repositories: abstract interface + `*Impl`; data sources for remote/local.

## ANTI-PATTERNS

- Do not put business logic in widgets or DB/HTTP concerns in BLoCs.
- Do not use relative imports for `lib/`; prefer package imports.
- Do not hardcode colors or strings; use `Theme.of(context)` and `context.l10n`.

## RELATED DOCS

- [lib/src/core/AGENTS.md](src/core/AGENTS.md)
- [lib/src/features/AGENTS.md](src/features/AGENTS.md)
- [lib/src/app/AGENTS.md](src/app/AGENTS.md)
