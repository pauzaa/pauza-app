# App – Application Shell
> See [/AGENTS.md](/AGENTS.md) for project-wide rules and [lib/AGENTS.md](../../AGENTS.md) for lib layout.

## OVERVIEW

`lib/src/app/` holds the application shell: `PauzaApp` (MaterialApp.router, theme, locale, router config), `RootScope` (providers for BLoCs and scopes used across the app). Entry point is `lib/main.dart` which delegates to `PauzaApp`.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| App widget, theme, locale, router | `pauza_app.dart` | `PauzaApp`, `themes`, `configs`, `supportedLanguages` |
| Root providers and scopes | `root_scope.dart` | `RootScope` wraps children with needed providers |
| Main entry | `lib/main.dart` | Delegates to `PauzaApp` |

## CONVENTIONS

- Theme and locale come from AppFuse state (`context.watchFuseState`, `context.readFuseState`).
- Router uses Helm; `RouterStateMixin` provides `router`; guards applied in `pauza_router_guards.dart`.
- `PauzaDependencies` is initialized in `PauzaApp.initState` and disposed in `dispose`.
- `RootScope` provides feature-level scopes (e.g. `SettingsScope`, navigation).

## ANTI-PATTERNS

- Do not put feature-specific logic in `PauzaApp`; keep it thin.
- Do not bypass `RootScope` when adding app-wide providers.
- Do not forget to dispose `PauzaDependencies` gates and repositories in `dispose`.
