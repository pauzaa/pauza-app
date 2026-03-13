# Routing
> See [AGENTS.md](/AGENTS.md) for project-wide rules and [lib/src/core/AGENTS.md](lib/src/core/AGENTS.md) for core layering.

## OVERVIEW

`routing/` configures Helm-based navigation. `PauzaRoutes` enum implements `Routable` with path, `PageType`, and builder for all screens. Guards for auth and permissions run before route resolution; stack normalization and deduplication live in `pauza_router_guards.dart`.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Route definitions | `pauza_routes.dart` | Enum values, paths, page types, builders |
| Router setup | `pauza_router.dart` | `HelmRouter`, `RouterStateMixin`, `Listenable.merge([permissionGate, authGate])` |
| Auth / permission guards | `pauza_router_guards.dart` | `createAuthGuard`, `createPermissionGuard`; stack normalization, deduping |

## CONVENTIONS

- Add new routes to `PauzaRoutes` enum; provide path, `PageType`, and builder.
- Guards run in order: empty page → auth → permission; guard logic stays in `pauza_router_guards.dart`.
- Use `PauzaRoutes` for navigation (e.g. `context.go(PauzaRoutes.home.path)`); do not hardcode paths.
- Router listens to `permissionGate` and `authGate` for guard re-evaluation.
- Use Helm `NavigationState` for declarative navigation; avoid imperative `Navigator.push` where possible.

## ANTI-PATTERNS

- Do not bypass guards when adding protected routes; all guarded routes go through `createAuthGuard` / `createPermissionGuard`.
- Do not hardcode route paths in widgets; use `PauzaRoutes.<route>.path`.
- Do not add routing logic outside `routing/`; keep route definitions centralized.
- Do not forget to register new screens in `PauzaRoutes` when adding features.
