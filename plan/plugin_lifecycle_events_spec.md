# Plugin Lifecycle Events: Spec and Execution Strategy

## Purpose
Define and implement durable lifecycle logging in `pauza_screen_time` so the host app can persist complete mode history for:
- `START`
- `PAUSE`
- `RESUME`
- `END`

This document is intended for an implementation agent working inside the plugin repository.

## Why this is needed
Manual transitions can be captured from app UI calls, but scheduled transitions are executed in native background flows:
- Android alarms + receivers
- iOS DeviceActivity monitor extension callbacks

Without plugin-level durable events, host app logs are incomplete whenever the app is backgrounded or killed.

## Required outcomes
1. Plugin becomes the source of truth for lifecycle transition events.
2. Events are durably queued in native storage.
3. Dart API exposes pull + ack APIs for host ingestion.
4. Delivery semantics are at-least-once, with host-side idempotent persistence.
5. Existing public behavior (`startSession`, `endSession`, `pauseEnforcement`, `resumeEnforcement`, schedules) remains compatible.

## Event model
Create a plugin event DTO with the following fields:
- `id`: unique event id (string, monotonic-friendly)
- `sessionId`: id of logical session
- `modeId`: mode identifier
- `modeTitleSnapshot`: optional in plugin internals, but exported as non-empty string when possible
- `action`: `START | PAUSE | RESUME | END`
- `source`: `manual | schedule`
- `reason`: transition reason tag (for diagnostics)
- `occurredAtEpochMs`: UTC epoch millis when transition happened

## Session semantics
- New `sessionId` is created on `START`.
- `PAUSE`, `RESUME`, `END` reuse active `sessionId`.
- If active mode/source changes without becoming inactive:
  - emit `END` for previous session
  - emit `START` for new session

## Transition rules
Compare previous and next resolved state:
- Inactive -> active: emit `START`
- Active -> inactive: emit `END`
- Not paused -> paused: emit `PAUSE`
- Paused -> not paused: emit `RESUME`
- Active old mode/source -> active new mode/source: emit `END` then `START`

Auto resume from pause expiry must emit `RESUME` (same semantics as manual resume).

## Dart API additions
Add to `AppRestrictionManager`:
- `Future<List<RestrictionLifecycleEvent>> getPendingLifecycleEvents({int limit = 200})`
- `Future<void> ackLifecycleEvents({required String throughEventId})`

Add method-channel names and platform interface methods accordingly.

## Native storage and queue requirements
Implement a persistent queue on both platforms:
- Ordered by insertion sequence.
- Supports fetch oldest-first with `limit`.
- Supports ack through inclusive event id.
- Bounded capacity (example: keep last 10k events) with deterministic pruning policy.

## Platform implementation points

### Android
Hook emission in places that mutate effective session state:
- manual start/end handlers
- pause/resume handlers
- schedule boundary handling in `RestrictionAlarmOrchestrator`
- pause-end alarm flow

Use shared persistent storage owned by plugin module. Keep write operations atomic for state+event emission.

### iOS
Hook emission in:
- `RestrictionsMethodHandler` manual start/end/pause/resume paths
- DeviceActivity extension callbacks:
  - `intervalDidStart`
  - `intervalDidEnd`

Store events in App Group shared storage so both extension and host app process can access same queue.

## Backward compatibility
- Keep current APIs unchanged.
- Introduce new APIs additively.
- If host app does not consume event APIs, restrictions still function as before.

## Error handling
- If event enqueue fails, do not silently break session mutation.
- Return/record a typed internal error where possible.
- Avoid app crash due to event logging path.

## Implementation sequence
1. Add Dart model + platform interface methods + method names.
2. Implement Android queue store + fetch/ack handlers.
3. Implement iOS queue store + fetch/ack handlers (App Group aware).
4. Wire transition-diff emission at all session/pause/schedule mutation points.
5. Add tests for transition mapping, queue fetch/ack, and duplicate delivery behavior.
6. Update plugin docs with API and semantics.

## Validation checklist
1. Manual flow: `START -> PAUSE -> RESUME -> END` emitted in order.
2. Scheduled start/end emitted while host app is terminated.
3. Pause auto-expiry emits `RESUME` if session remains active.
4. If schedule ended during pause, no invalid extra `RESUME`.
5. Fetch without ack redelivers same events.
6. Ack removes only events up to `throughEventId`.

## Definition of done
- New lifecycle APIs available in Dart and native handlers.
- Events emitted for manual and scheduled transitions.
- Queue persistence works across process death and reboot scenarios supported by current plugin.
- Automated tests cover key transition and queue semantics.
- Documentation updated and publish-ready.
