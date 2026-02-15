# Plugin Documentation Plan for Host App Integration

## Purpose
After lifecycle-event support is implemented in `pauza_screen_time`, publish documentation that lets host apps integrate it without reading plugin internals.

This plan defines what documentation must be created, what technical detail is mandatory, and what host developers need to safely implement ingestion into their local database.

## Audience
- Host app engineers integrating `pauza_screen_time`
- QA engineers validating lifecycle logs
- Future maintainers upgrading plugin versions

## Documentation deliverables
Create/update these docs in the plugin repo:
1. `docs/restrict-apps.md` update:
   - add lifecycle events section
   - add new API methods
2. New `docs/restriction-lifecycle-events.md`:
   - full event model, queue semantics, examples
3. `docs/troubleshooting.md` update:
   - event delivery and ack failure scenarios
4. `CHANGELOG.md`:
   - additive API and behavior notes

## Mandatory technical content

### 1) Event data contract
Document every field:
- `id`
- `sessionId`
- `modeId`
- `modeTitleSnapshot`
- `action`
- `source`
- `reason`
- `occurredAtEpochMs`

Include guarantees:
- ordering per queue
- at-least-once delivery
- possible redelivery before ack

### 2) Transition semantics
Document exact mapping:
- inactive -> active = `START`
- active -> inactive = `END`
- unpaused -> paused = `PAUSE`
- paused -> unpaused = `RESUME`

Include rule for mode/source switch (`END` then `START`) and pause auto-expiry behavior.

### 3) Queue API contract
Document new APIs:
- `getPendingLifecycleEvents(limit)`
- `ackLifecycleEvents(throughEventId)`

Clarify:
- ack is inclusive
- host must ack only after durable persistence
- recommended batch size and polling triggers

### 4) Platform behavior notes
Explain where scheduled events are produced:
- Android alarm/receiver background flow
- iOS DeviceActivity extension callbacks

Clarify that host app cannot reliably infer these transitions from UI lifecycle.

### 5) Failure and recovery behavior
Document expected behavior when:
- app crashes after insert but before ack
- plugin redelivers already-fetched events
- queue reaches max capacity and pruning applies

## Host app integration guide (must include runnable snippets)

Provide a complete integration section with:
1. local DB schema recommendation for mode session events
2. idempotent insert pattern (`INSERT OR IGNORE` keyed by event `id`)
3. sync loop pseudocode:
   - fetch batch
   - transaction insert
   - ack through last event id
   - repeat
4. recommended sync triggers:
   - app startup
   - app foreground resume
   - after manual lifecycle actions

## Acceptance criteria for docs
1. A host engineer can implement ingestion without opening native plugin code.
2. Event semantics and ordering are explicit and testable.
3. Ack contract and duplicate-handling strategy are unambiguous.
4. Scheduled transition origin is clearly documented for both platforms.
5. Troubleshooting covers stale queue, redelivery, and missing-permission edge cases.

## Suggested host app checklist (to include in docs)
1. Add DB migration for lifecycle events table.
2. Implement repository sync from plugin queue.
3. Use idempotent event persistence.
4. Ack only after transaction commit.
5. Add startup/resume sync triggers.
6. Add integration tests for duplicate delivery and batch ack.

## Release and versioning notes
- Mark feature as additive and backward compatible.
- Include minimum plugin version required by host app docs.
- Include upgrade note: host app should ship ingestion before relying on analytics/history built from lifecycle events.
