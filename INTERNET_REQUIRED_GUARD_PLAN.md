# Internet Guarding Implementation Plan (Offline-First Compatible)

## Summary
Introduce a consistent internet guard strategy that preserves offline-first navigation while blocking only internet-dependent operations:
1. `Leaderboard` always opens, but renders an offline stub when internet is unhealthy.
2. `Auth` submit/OTP submit are guarded before dispatch.
3. `Profile edit` save/username-check/photo-upload are guarded before remote calls.
4. No global periodic polling timer in `InternetHealthGate`; use event-driven refresh + on-demand preflight refresh for guarded actions.

## Design Decisions (Locked)
- `Leaderboard offline policy`: open screen and show offline stub with retry.
- `Action behavior`: tap-to-toast guard (do not dispatch operation when offline).
- `Health refresh policy`: event-driven (`connectivity` + app resume) plus preflight refresh on guarded actions.
- `Periodic timer`: do **not** add a global periodic timer now.
- Rationale: avoids battery/network overhead, avoids background polling complexity, and preflight checks guarantee freshness exactly when needed.

## Important API / Interface / Type Changes
1. New guard interface and implementation:
- New file: `lib/src/core/connectivity/domain/internet_required_guard.dart`
- API:
  - `abstract interface class InternetRequiredGuard`
  - `Future<bool> canProceed({bool forceRefresh = true})`
  - `bool get isHealthy`
- Implementation delegates to existing `InternetHealthGate`.

2. Global app error model (single source of truth):
- New file: `lib/src/core/common/model/pauza_app_error.dart`
- Add enum/class for cross-feature failures used by guarded actions.
- Required case: `internetUnavailable`.
- All guarded flows (auth/profile/username check/photo upload) use this shared error instead of feature-specific offline errors.

3. Username availability extension:
- Update `lib/src/features/profile/edit/bloc/user_name_checker_bloc.dart`
- Add enum case: `offline`
- Use `offline` specifically for no-internet state.

4. Validation mapping:
- Update `lib/src/core/common/validation.dart`
- Map `UsernameAvailability.offline` to `profileEditOfflineUsernameCheckError`.

5. Universal screen widget:
- New file: `lib/src/core/common_ui/no_internet_state.dart`
  - Pure presentational widget with title, message, retry button.
- New file: `lib/src/core/connectivity/widget/internet_required_body.dart`
  - Reusable wrapper that listens to `InternetHealthGate` and switches:
    - healthy -> provided `child`
    - unhealthy -> `NoInternetState`

## Implementation Plan

## 1) Core guard abstraction and DI
- Add guard file with:
  - `InternetRequiredGuardImpl({required InternetHealthGate internetHealthGate})`.
  - `canProceed(forceRefresh: true)` calls `refresh(force: true)` then returns `isHealthy`.
  - `canProceed(forceRefresh: false)` calls `refresh(force: false)` then returns `isHealthy`.
- Wire in `lib/src/core/init/pauza_dependencies.dart`:
  - add `late final InternetRequiredGuard internetRequiredGuard;`
  - initialize right after internet gate init.
- No change to `InternetHealthGateNotifier` refresh strategy (no periodic timer).

## 2) Universal offline screen widget
- `NoInternetState`:
  - uses `Theme.of(context)` only.
  - shows icon/title/message/retry button.
  - retry callback is async-capable via wrapper.
- `InternetRequiredBody`:
  - constructor:
    - `required InternetHealthGate gate`
    - `required Widget child`
    - optional overrides for title/message/button labels (defaults from `l10n`).
  - body:
    - `AnimatedBuilder(animation: gate, ...)`.
    - if healthy -> `child`.
    - if unhealthy -> `NoInternetState(onRetry: () => gate.refresh(force: true))`.

## 3) Leaderboard integration (screen-level)
- Update `lib/src/features/leaderboard/widget/leaderboard_screen.dart`:
  - keep `Scaffold`.
  - scaffold body becomes `InternetRequiredBody(...)`.
  - pass `PauzaDependencies.of(context).internetHealthGate`.
  - healthy branch content = existing leaderboard content.
  - offline branch uses localized keys:
    - `leaderboardOfflineTitle`
    - `leaderboardOfflineMessage`
    - `leaderboardRetryButton`

## 4) Auth action guards
- Update `lib/src/features/auth/bloc/auth_bloc.dart`:
  - inject `InternetRequiredGuard`.
  - in `_onSignInRequested` and `_onOtpSubmitted`:
    - call `canProceed(forceRefresh: true)` before repository calls.
    - if false -> emit failure based on global `PauzaAppError.internetUnavailable` and return.
- Update `lib/src/features/auth/common/model/auth_failure.dart`:
  - remove/avoid auth-specific internet unavailable enum.
  - map global error to existing auth failure state contract.
- Update `lib/src/app/root_scope.dart`:
  - pass `dependencies.internetRequiredGuard` to `AuthBloc` constructor.

## 5) Profile edit action guards
- Update `lib/src/features/profile/edit/bloc/profile_edit_bloc.dart`:
  - inject `InternetRequiredGuard`.
  - preflight in `_onSaveRequested`.
  - offline -> emit failure using global `PauzaAppError.internetUnavailable` mapping.
- Update `lib/src/features/profile/edit/bloc/user_name_checker_bloc.dart`:
  - inject `InternetRequiredGuard`.
  - preflight before repository call.
  - offline -> emit `UsernameAvailability.offline`, return early.
- Update `lib/src/features/profile/edit/widget/profile_edit_screen.dart`:
  - inject guard into `ProfileEditBloc` and `UserNameCheckerBloc`.
- Photo upload guard:
  - in photo upload trigger flow (avatar/photo action handler), run same preflight before calling repository upload; show existing failure path/toast.

## 6) Localization
- Update ARB files:
  - `assets/l10n/app_en.arb`
  - `assets/l10n/app_ru.arb`
  - `assets/l10n/app_uz.arb`
  - `assets/l10n/app_uz_Cyrl.arb`
- Add keys:
  - `internetRequiredToast`
  - `leaderboardOfflineTitle`
  - `leaderboardOfflineMessage`
  - `leaderboardRetryButton`
  - `profileEditOfflineUsernameCheckError`
- Run `flutter gen-l10n`.

## 7) Timer decision (explicit)
- Do **not** add periodic timer to `InternetHealthGateNotifier`.
- Freshness guarantees come from:
  - startup force refresh
  - app resume refresh
  - connectivity-change refresh
  - preflight force refresh on guarded actions
  - manual retry button on offline screen

## Test Cases and Scenarios

## Unit tests
1. `InternetRequiredGuard`:
- `canProceed(forceRefresh: true)` calls refresh with force and returns health.
- `canProceed(forceRefresh: false)` respects non-force refresh path.

2. `AuthBloc`:
- offline sign-in emits failure derived from global `PauzaAppError.internetUnavailable` and no repository call.
- offline OTP emits same and no repository call.
- online paths remain unchanged.

3. `ProfileEditBloc`:
- offline save emits failure derived from global `PauzaAppError.internetUnavailable` and no repository update call.

4. `UserNameCheckerBloc`:
- offline emits `UsernameAvailability.offline`.
- online still emits `checking -> available/taken`.

## Widget tests
1. `LeaderboardScreen`:
- unhealthy: offline title/message/retry button visible.
- healthy: offline widget absent, leaderboard content visible.
- retry tap triggers `refresh(force: true)`.

2. Validation/UI:
- username field shows `profileEditOfflineUsernameCheckError` when bloc state is `offline`.

## Regression checks
- Existing `internet_health_gate_notifier_test.dart` stays valid.
- Auth/profile existing tests updated only where new failure enums/messages affect expectations.

## Acceptance Criteria
1. Offline user can open app and navigate tabs normally.
2. Opening leaderboard offline shows explicit offline UI with retry.
3. Login/OTP/profile-save/username-check do not perform remote calls when offline.
4. User sees localized internet-required feedback for blocked actions.
5. Internet regained + retry causes guarded features to work without app restart.
6. No periodic global timer added; behavior remains responsive through event + preflight refresh.

## Assumptions and Defaults
- Existing screen-level scaffold structures remain; only body gating is added.
- Offline text for non-English locales can start as product placeholders.
- “Tap-to-toast” behavior is preserved via existing bloc failure listeners; no extra direct UI toasts added.
- If later needed, the same `InternetRequiredBody` can be reused on any internet-required screen with zero custom logic.
