# Auth Feature
> See [lib/src/features/AGENTS.md](../AGENTS.md) for feature layout and [/AGENTS.md](/AGENTS.md) for project-wide rules.

## OVERVIEW

`auth/` handles passwordless login (email start → OTP verify), session management, token refresh, and sign-out. Uses `AuthRepository`, `AuthSessionStorage`, `AuthRemoteDataSource`, and `PauzaAuthGate` for gate-based routing. Requires `InternetRequiredGuard` for start/verify flows.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Auth screen, OTP screen | `widget/` | `AuthScreen`, `OtpScreen`; `auth_form/`, `otp_code/` subfolders |
| Auth state machine | `bloc/` | `AuthBloc`, events, states |
| Session, token storage | `data/` | `AuthRepository`, `AuthSessionStorage`, `AuthRemoteDataSource` |
| Auth gate (routing) | `domain/` | `PauzaAuthGate`, used by router guards |
| User DTO (from auth) | `common/model/` | Auth returns user data; profile consumes |

## CONVENTIONS

- Session stored securely via `AuthSessionStorage`; refreshed via `AuthRepository.refreshSession()`.
- API client uses `ApiClientAuthMiddleware` with token from `authRepository.currentSession`.
- Auth gate notifies router when auth state changes; guards redirect unauthenticated users.
- On sign-out: `syncLocalDataSource.clearAllSyncableTables()` called via `onSignOutCleanup`.

## ANTI-PATTERNS

- Do not leak account existence via error messages or timing in OTP flows.
- Do not put token or credential logic in widget layer; keep in repository/domain.
- Do not bypass `InternetRequiredGuard` for start/verify; these flows need connectivity.
