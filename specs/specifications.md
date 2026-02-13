# Pauza — Product Specifications (v1)

**Status:** Draft  
**Last updated:** 2026-02-07  
**Owner:** Pauza team

## 0) Product framing
Pauza is a Modes-based behavior intervention system:

- **Tracking** (usage + sessions) → **intelligence** (AI insights) → **intervention** (hard blocking) → **analytics** (charts + streaks).
- **Offline-first** for Modes, schedules, enforcement, and session logging.
- **Hard-only** intervention: no “soft warnings”.
- **Stop/Pause requires friction**: NFC is the primary mechanism; **PIN + cooldown** is the fallback.

## 1) Core product model (“Modes”)

### 1.1 Mode
A **Mode** is a named configuration that defines:

- **Blocked apps set**
  - Android: selected by installed package IDs (plus labels/icons for UI).
  - iOS: selected via Screen Time picker tokens (FamilyControls).
- **Stop policy**
  - **Required to configure during Mode creation/edit**
  - Primary: **NFC tag scan required**
  - Fallback: **PIN + cooldown** (enabled in v1; NFC remains the differentiator)
- **Pause policy**
  - enabled/disabled
  - allowed durations (default: 5/10/15 minutes)
  - max pauses per session (default: 0–3; per-mode)
- **Escalation rules (optional, v1 static)**
  - “blocked attempts” friction rules (e.g., increase PIN cooldown after N stop requests/blocked attempts within a short window)
  - no adaptive/AI-driven escalation in v1
- **Schedule(s) (optional)**
  - day-of-week + start/end times
  - “force start if already in distracting apps” (enabled)
  - **no overlaps allowed** (see Scheduling section)

#### Mode invariants
- A Mode can be active for **at most one session at a time** (per device).
- At most **one Mode is active at a time** (v1).
- The blocked set must not be empty (unless explicitly allowing “schedule-only session tracking”, which is out of scope v1).
- Stop/pause unlock method(s) must be configured at Mode creation/edit:
  - if NFC is enabled → at least one NFC tag must be registered
  - if PIN fallback is enabled → PIN must be set

### 1.2 Mode session
A **Mode Session** is created when a Mode starts (manual or scheduled) and is the backbone for streaks + evaluation.

Track (minimum):

- **Identity**
  - `id`, `modeId`, `deviceId`, `userId`
- **Timing**
  - `startedAt`, `endedAt` (nullable while active)
  - `endedReason`: `userStop` | `scheduleEnd` | `appCrashRecovery` | `systemStop` (platform-specific)
- **Pauses**
  - `pauseCount`
  - `pausedTotalMinutes`
  - pause events: `startedAt`, `endedAt`, `durationMinutes`, `unlockMethod` (NFC vs PIN)
- **Intervention interaction**
  - `blockedAttemptsCount` (Android required; iOS best-effort)
  - `overrideCount` (v1 == number of PIN-based stop/pause unlocks; NFC is not an override)
- **Outcome**
  - `isSuccessful`: boolean (definition below)
  - `failureReason` (nullable)
- **Streak contribution**
  - `countsTowardStreak`: boolean (computed)

#### Session success definition (v1)
A session is **successful** if:

- it ends via `scheduleEnd`, **or**
- it ends via `userStop` *after* meeting a minimum duration threshold (configurable; default: 10 minutes), **or**
- it remains active past a configured “completion point” (for open-ended sessions; optional).

## 2) Feature list (BIS pillars)

### A) Intervention engine (differentiator)

#### A1) Manual start
- From Mode detail: **Start**
- Starts enforcement immediately.
- Creates a new Mode Session.

#### A2) Scheduled start/stop (offline-first)
- Per-mode schedule windows can start/stop the mode locally.
- “Force start if already in distracting apps”:
  - if schedule starts while the user is inside a blocked app, enforcement activates immediately and the blocked app becomes inaccessible.

#### A3) Hard block (Android)
- Prevent access to selected apps using Accessibility-based enforcement (or via `pauza_screen_time` if it encapsulates this).
- Must detect foreground app changes and apply blocking when the app is in the blocked set.

#### A4) Shield (“blocked screen”) UX rules
When a blocked app is opened during an active Mode:

- Show a **shield screen** that explains the block.
- The shield screen **must not allow Stop or Pause**.
- The only action is to **open Pauza** to Stop/Pause (NFC/PIN flow happens inside the app).

Shield content (minimum):
- Mode name
- “This app is blocked”
- time remaining (if Mode has a scheduled end)
- “Open Pauza to stop/pause”

Shield is enforced via `pauza_screen_time` plugin

#### A5) Escalation rules (static, optional)
No “soft warning” stage in v1. Only hard block.

### B) NFC controls (signature mechanism) + PIN fallback

#### B1) NFC registration
- User registers allowed NFC tag(s).
- Local store: raw tag UID may be stored (secure storage).
- Backend store: **hash of UID only** (no raw UID).

#### B2) Stop requires NFC (primary path)
- Stopping a Mode requires scanning a registered NFC tag inside the app.

#### B3) Pause requires NFC (same rule)
- Pausing a Mode requires the same NFC scan inside the app.

#### B4) Fallback: PIN with cooldown (official alternative in v1)
When NFC is unavailable or refused:

- User sets a **PIN**.
- Stop/Pause is allowed only after a **cooldown delay** (configurable; default: 60 seconds).
- Flow:
  1) user taps Stop/Pause → cooldown countdown starts
  2) after countdown → user enters PIN
  3) if PIN correct → stop/pause executes

Constraints:
- PIN is stored locally in secure storage (hashed/derived; never plaintext).
- Every PIN unlock increments `overrideCount` and is logged.

### C) Scheduling

#### C1) Per-mode schedules
Each schedule window includes:

- days of week
- start time
- end time
- enable/disable flag

#### C2) Overlap policy (v1 simplification)
- **Schedule conflicts are not possible** in v1:
  - the app must prevent creating overlapping windows (including across different Modes)
  - backend must validate the same rule on sync

#### C3) Offline-first execution
- Schedules must run locally:
  - Android: alarms/foreground service as needed
  - iOS: Screen Time / DeviceActivity scheduling mechanisms
- Backend is only for syncing configuration; it is not responsible for triggering starts/stops.

### D) Tracking & analytics

#### D1) App usage statistics (Android: full)
- Collect per-app usage via `UsageStatsManager` (requires Usage Access).
- Store locally as aggregates (not raw event timelines).

Aggregations:
- daily total screen time
- per-app minutes
- category minutes (local mapping)
- hourly heatmap (24 buckets)

#### D2) App usage statistics (iOS: UI-based)
- Use Screen Time reporting (DeviceActivityReport).
- Show usage stats via **PlatformView** (native UI embedded in Flutter).
- Due to sandboxing, treat iOS usage reports as **visualization-first** (no AI ingestion in v1).

#### D3) Mode usage tracking (both platforms)
Track and visualize:
- session count/day
- success rate
- pause count + paused minutes
- blocked attempts (Android; iOS best-effort)
- streaks

#### D4) MVP visualizations
- Focus/discipline score trend (derived from sessions + usage)
- Sessions completed vs failed
- Top distracting apps (Android)
- Time-of-day distraction heatmap (Android)

### E) AI insights

#### E1) Scope (v1)
- **Android only**.
- iOS: **no AI insights** in v1.

#### E2) Input data policy (v1 decision)
- Send **full identifiers + timestamps** to AI for best-quality insights:
  - package IDs/app identifiers
  - usage aggregates + time buckets
  - mode session logs (including pauses, stops, attempts)
- No user toggle in v1 (privacy controls are a future item).

#### E3) Output requirements
AI produces (minimum):
- “What’s driving distraction this week?”
- “Risk hours” forecast (time ranges with elevated distraction probability)
- recommendations (e.g., schedule suggestions, mode tuning, blocked list suggestions)

Constraints:
- AI does **not** enforce adaptive escalation in v1; it only recommends.

#### E4) History
- Store AI insight history (text + metadata) in backend and cache locally.

### F) Backend + offline-first sync

#### F1) Backend stores (v1)
- user account/auth
- modes + schedules
- NFC registrations (hash only)
- mode session logs (aggregated)
- AI insight history (text only + metadata)

#### F2) Backend does not store (v1)
- raw app usage timelines/events (Android)
- iOS app usage data (beyond what’s needed for on-device visualization)

#### F3) Offline-first sync model
- Local DB is the source of truth.
- Every change writes locally first and is enqueued in a sync outbox.
- Sync is eventually consistent.
- Conflict policy: **last-write-wins** using `updatedAt` timestamps.

## 3) Platform implementation notes

### 3.1 Android
Required capabilities:

- permissions helpers:
  - open Usage Access settings
  - open Accessibility settings
- installed apps list (package, label, icon)
- usage stats query (by date range + granularity)
- enforcement:
  - start blocking for active mode
  - stop blocking
  - emit “blocked attempt” events
- NFC scanning: return tag UID
- scheduling hooks: run schedules offline

### 3.2 iOS (Screen Time APIs)
Required capabilities:

- Screen Time authorization (FamilyControls)
- app selection picker (tokens)
- shielding/monitoring:
  - start shield for active mode
  - stop shield
  - pause shield for duration
- scheduling:
  - start/stop shielding based on schedule windows
- usage stats visualization:
  - DeviceActivityReport embedded as a PlatformView

Scope limitations (v1):
- AI insights not available on iOS.

## 4) Flutter ↔ native capability layer (plugin contract)
This project uses the `pauza_screen_time` plugin as the platform capability layer (see `specs/technical_details.md`).

The app-level contract (what Flutter must be able to do) includes:

### 4.1 Shared
- list/edit Mode blocked apps selection (Android packages, iOS tokens)
- start/stop/pause current Mode enforcement
- register and scan NFC (if supported)

### 4.2 Android APIs (minimum)
- `getInstalledApps()` (package + label + icon)
- `openUsageAccessSettings()`, `isUsageAccessGranted()`
- `openAccessibilitySettings()`, `isAccessibilityEnabled()`
- `queryUsageStats(start, end, granularity)` → aggregates
- `startBlocking(blockedPackages, modeId)`, `stopBlocking()`
- events stream:
  - `onBlockedAttempt(package, timestamp)`
  - `onEnforcementStateChanged(active, modeId)`
- `startNfcScan()` → tag UID (string/bytes)
- schedule registration/cancel

### 4.3 iOS APIs (minimum)
- `requestAuthorization()`
- `presentAppPicker()` → selection tokens
- `startShielding(modeId)`, `stopShielding(modeId)`, `pauseShielding(modeId, duration)`
- schedule registration/cancel
- `createUsageReportView(dateRange|modeId)` → PlatformView handle

## 5) UI/UX screens (MVP)

### 5.1 Onboarding
- explain Modes + hard blocking
- Android setup (Usage Access + Accessibility)
- iOS setup (Screen Time authorization + picker)
- create first Mode

### 5.2 Modes
- Modes list (create/edit/delete)
- Mode editor:
  - name
  - blocked apps selection
  - pause policy
  - stop/pause unlock policy (NFC required, optional PIN cooldown fallback)
  - schedules editor (no overlaps)

### 5.3 Active mode
- Mode status (active)
- remaining time (if scheduled)
- pause buttons (if allowed) with preset durations
- stop flow entry:
  - NFC scan
  - PIN + cooldown fallback
- live counters:
  - blocked attempts (Android)
  - pauses used / remaining

### 5.4 Shield screen (system)
- “This app is blocked” + mode name + time remaining
- only CTA: “Open Pauza”
- no stop/pause controls

### 5.5 Analytics
- Android: charts + top apps + heatmap
- iOS: PlatformView usage report + session analytics

### 5.6 AI insights (Android)
- latest insight
- risk hours forecast
- recommendations list
- history

### 5.7 Settings
- NFC tag management
- PIN management
- schedules overview
- sync status

## 6) Security & privacy (v1)
- NFC: store raw UID locally; backend stores only salted hash.
- PIN: store derived hash locally; never store plaintext.
- AI: send full identifiers/timestamps (Android) per v1 decision; store only insight output in backend.

## 7) Acceptance criteria (v1)
- User can create/edit/delete a Mode with a blocked app set.
- User can start/stop/pause a Mode manually.
- Schedules start/stop Modes locally, offline-first.
- Schedules cannot overlap (creation is blocked in UI and validated on sync).
- When Mode is active, blocked apps are inaccessible via a hard shield.
- Shield screen does not allow stop/pause; user must open Pauza to perform NFC/PIN flow.
- NFC stop/pause works with registered tag(s).
- PIN + cooldown stop/pause works and is logged as an override.
- Mode sessions are logged with start/end, pauses, blocked attempts, and success flags.
- Android shows usage analytics (daily/weekly + heatmap) and can generate AI insights; AI insight history is stored.
- iOS enforces restrictions via Screen Time APIs and shows usage stats via PlatformView; AI insights are not available.

## 8) Out of scope (explicitly)
- Soft warnings before blocking.
- Overlapping schedules / schedule conflict resolution.
- iOS AI insights (v1).
- Adaptive enforcement escalation driven by AI (v1).
