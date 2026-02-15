# Mode Lifecycle Logging: Technical Implementation Details

## Context
This document describes the host-app implementation for durable mode lifecycle logging based on `pauza_screen_time` lifecycle queue APIs.

Implemented lifecycle actions:
- `START`
- `PAUSE`
- `RESUME`
- `END`

The plugin is treated as source of truth for transition events. The host app ingests events from plugin queue, persists idempotently, derives session aggregates, and acknowledges only after durable commit.

## High-Level Architecture
Two persistent tables are used:
1. `restriction_lifecycle_events` (canonical append-only event log)
2. `restriction_sessions` (derived session projection keyed by plugin `session_id`)

Sync flow:
1. Pull batch from plugin queue (`getPendingLifecycleEvents(limit)`)
2. Transactionally persist each event and update session projection
3. Commit transaction
4. Ack plugin queue through last event id (`ackLifecycleEvents(throughEventId)`)
5. Repeat until queue is empty

This yields at-least-once ingestion safety with idempotent durability.

## Files Added / Updated

### Database
- `lib/src/core/local_database/local_database_config.dart`
  - Database version set to `3`.

- `lib/src/core/local_database/pauza_local_database_schema_v1.dart`
  - Added lifecycle tables and indexes in `onCreate`.
  - `onUpgrade` intentionally left empty (fresh installs only).

### Lifecycle feature
- `lib/src/features/restriction_lifecycle/common/model/restriction_lifecycle_event_log.dart`
  - Typed event log model.
  - Uses plugin enums:
    - `RestrictionLifecycleAction`
    - `RestrictionLifecycleSource`
  - Uses `DateTime` for timestamps:
    - `occurredAt`
    - `createdAt`

- `lib/src/features/restriction_lifecycle/common/model/restriction_session_log.dart`
  - Typed session projection model.
  - Uses plugin enum `RestrictionLifecycleSource`.
  - Uses `DateTime` timestamps:
    - `startedAt`, `endedAt`, `lastPausedAt`, `createdAt`, `updatedAt`

- `lib/src/features/restriction_lifecycle/data/restriction_session_reducer.dart`
  - Session state machine/reducer from event stream.
  - Produces create/update patches and anomaly marking.

- `lib/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart`
  - Repository contract + implementation.
  - Plugin client abstraction and concrete wrapper for `AppRestrictionManager`.
  - Sync loop, idempotent insert, session projection updates, and post-commit ack.

- `lib/src/features/restriction_lifecycle/sync/restriction_lifecycle_sync_coordinator.dart`
  - `WidgetsBindingObserver` coordinator.
  - Triggers sync on app foreground resume.

### Wiring / integration
- `lib/src/core/common/pauza_dependencies.dart`
  - Constructs `RestrictionLifecycleRepository`.
  - Performs best-effort startup sync.

- `lib/src/app/root_scope.dart`
  - Creates and attaches `RestrictionLifecycleSyncCoordinator`.
  - Detaches coordinator on dispose.

- `lib/src/features/home/data/pauza_blocking_repository.dart`
  - Extended with `syncRestrictionLifecycleEvents()` hook.
  - Triggers best-effort sync after successful manual `startSession` and `endSession` calls.

- `lib/src/features/home/bloc/blocking_bloc.dart`
  - `BlockingSyncRequested` now syncs lifecycle queue before reading current plugin session snapshot.

### Tests
- `test/features/restriction_lifecycle/data/restriction_session_reducer_test.dart`
  - Reducer behavior for happy path and anomaly scenarios.

## Database Schema (Current)

### `restriction_lifecycle_events`
Columns:
- `id TEXT PRIMARY KEY NOT NULL`
- `session_id TEXT NOT NULL`
- `mode_id TEXT NOT NULL`
- `action TEXT NOT NULL CHECK(action IN ('START','PAUSE','RESUME','END'))`
- `source TEXT NOT NULL CHECK(source IN ('manual','schedule'))`
- `reason TEXT NOT NULL`
- `occurred_at INTEGER NOT NULL`
- `created_at INTEGER NOT NULL`

Indexes:
- `idx_restriction_events_session_occurred_at` on `(session_id, occurred_at)`
- `idx_restriction_events_mode_occurred_at` on `(mode_id, occurred_at)`
- `idx_restriction_events_occurred_at` on `(occurred_at)`

### `restriction_sessions`
Columns:
- `session_id TEXT PRIMARY KEY NOT NULL`
- `mode_id TEXT NOT NULL`
- `source TEXT NOT NULL CHECK(source IN ('manual','schedule'))`
- `started_at INTEGER NOT NULL`
- `ended_at INTEGER`
- `pause_count INTEGER NOT NULL DEFAULT 0`
- `total_paused_ms INTEGER NOT NULL DEFAULT 0`
- `last_paused_at INTEGER`
- `integrity_status TEXT NOT NULL DEFAULT 'ok' CHECK(integrity_status IN ('ok','anomaly'))`
- `last_anomaly_reason TEXT`
- `last_event_id TEXT NOT NULL`
- `created_at INTEGER NOT NULL`
- `updated_at INTEGER NOT NULL`

Indexes:
- `idx_restriction_sessions_mode_started_at` on `(mode_id, started_at DESC)`
- `idx_restriction_sessions_ended_at` on `(ended_at)`

## Ingestion Mechanics

## 1) Fetch and batching
Repository method:
- `syncFromPluginQueue({int batchSize = 200})`

Loop behavior:
- Pull oldest-first plugin events with configured `limit`.
- Exit when batch is empty.

## 2) Idempotent persistence
For each event in transaction:
- `INSERT OR IGNORE` into `restriction_lifecycle_events` by `id`.
- If insert ignored (duplicate redelivery), skip session projection update for that event.

This ensures redelivery safety and stable reprocessing behavior.

## 3) Session projection updates
For newly inserted events only:
- Load session snapshot by `session_id`.
- Pass event + snapshot to reducer.
- Apply reducer patch:
  - insert new session row, or
  - update existing session row.

## 4) Ack contract
After transaction commit:
- Ack through last event id in batch.

Ack is intentionally outside transaction and only executed after durable commit.

## Reducer / State Machine
Reducer lives in `restriction_session_reducer.dart` and encodes deterministic transitions.

### Snapshot missing
- `START` -> create normal session row.
- `PAUSE`/`RESUME`/`END` -> create anomaly session row (`integrity_status='anomaly'`) and preserve raw event.

### Snapshot exists
- `START`
  - Marks anomaly (`start_when_session_active` or `duplicate_start_for_session`).
  - Does not destroy existing aggregate timeline.

- `PAUSE`
  - If ended -> anomaly `pause_after_end`.
  - If already paused -> anomaly `pause_when_already_paused`.
  - Else increments `pause_count`, sets `last_paused_at`.

- `RESUME`
  - If ended -> anomaly `resume_after_end`.
  - If not paused -> anomaly `resume_without_pause`.
  - Else accumulates pause duration (`occurred_at - last_paused_at`) and clears `last_paused_at`.

- `END`
  - If already ended -> anomaly `duplicate_end_for_session`.
  - Else sets `ended_at`; if currently paused, closes pause window at end timestamp.

Always updates:
- `last_event_id`
- `updated_at`

## Trigger Points Implemented

### Startup
- Best-effort sync executed during dependency initialization after manager/repository creation.
- Failures are swallowed to avoid blocking app startup.

### Foreground resume
- Coordinator observes lifecycle; on `AppLifecycleState.resumed` triggers sync.
- Uses in-flight guard to avoid overlapping sync calls.

### Manual lifecycle actions
- After successful manual `startSession` and `endSession`, repository performs best-effort sync.
- Sync failures do not fail manual action completion.

## Type and Time Semantics

### DB storage
- DB stores timestamps as `INTEGER` epoch millis for efficient indexing/sorting.

### Domain model exposure
- Exposed as `DateTime` in event/session log models.
- Row mappers convert integer millis -> UTC `DateTime`.

### Enums
- Action/source use plugin enums in event model.
- Source uses plugin enum in session model.
- This keeps host typings aligned with plugin contract.

## Operational Guarantees

1. **At-least-once compatible ingestion**
   - Duplicate delivery is expected and harmless due to PK + `INSERT OR IGNORE`.

2. **Ack-after-commit safety**
   - Event loss is avoided if crash happens before ack.

3. **Projection resilience**
   - Raw event log remains authoritative.
   - Session projection records anomalies rather than dropping inconsistent events.

4. **Fresh-install assumption**
   - No migration path is provided (`onUpgrade` no-op) by explicit product choice.

## Current Test Coverage

Reducer tests verify:
- `START -> PAUSE -> RESUME -> END` aggregate correctness
- `END` while paused closes pause window
- `PAUSE` without prior `START` anomaly creation
- duplicate `START` anomaly behavior

Analyzer and tests pass on current branch.
