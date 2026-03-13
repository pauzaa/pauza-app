# API Client
> See [AGENTS.md](/AGENTS.md) for project-wide rules and [lib/src/core/AGENTS.md](lib/src/core/AGENTS.md) for core layering.

## OVERVIEW

`api_client/` provides the HTTP client for REST API calls. `ApiClient` supports GET/POST/PUT/PATCH/DELETE with JSON, middleware pipeline (logger → auth → retry), and a sealed exception hierarchy for client/network/authorization errors.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| HTTP requests, JSON handling | `api_client.dart` | `ApiClient`, `ApiClientRequest`, `ApiClientResponse`, `ApiClientException` hierarchy |
| Bearer token, refresh on 401/403 | `middleware/auth_mw.dart` | `ApiClientAuthMiddleware`; token provider and refresher from `PauzaDependencies` |
| Retry with backoff | `middleware/retry_mw.dart` | `ApiClientRetryMiddleware` for network errors |
| Request/response logging | `middleware/logger_mw.dart` | `ApiClientLoggerMiddleware` |
| Accept-Language injection | `middleware/lang_mw.dart` | Not wired in `PauzaDependencies` yet |

## CONVENTIONS

- Middleware order in `PauzaDependencies`: Logger → Auth → Retry.
- Exceptions implement `Localizable` for user-facing messages.
- Use `ApiClient` from `PauzaDependencies.of(context)`; do not instantiate directly in features.
- Data sources (auth, friends, leaderboard, profile, sync, ai) call `ApiClient`; repositories orchestrate data sources.

## ANTI-PATTERNS

- Do not put business logic in middleware; keep middleware stateless and cross-cutting.
- Do not bypass middleware order when adding new middleware.
- Do not hardcode base URL or tokens; they come from `PauzaConfig` and `AuthRepository`.
