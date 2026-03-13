# Modes Feature
> See [lib/src/features/AGENTS.md](../AGENTS.md) for feature layout and [/AGENTS.md](/AGENTS.md) for project-wide rules.

## OVERVIEW

`modes/` handles mode CRUD (create, read, update, delete), mode editor UI, modes list, and app selection for restricted apps. Uses `LocalDatabase` and `SyncLocalDataSource` for persistence and sync; `pauza_screen_time` for app restriction and installed apps. Subfeatures: `add_edit/`, `list/`, `select_apps/`.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Mode CRUD, persistence | `common/data/` | `ModesRepository`, row mapping, sync table |
| Mode editor UI | `add_edit/` | `ModeEditorBloc`, `ModeEditorScreen`, editor widgets |
| Modes list | `list/` | `ModesListBloc`, list widget |
| App selection for modes | `select_apps/` | `InstalledAppsBloc`, `PauzaScreenTimeInstalledAppsRepository` |
| Mode model, DTOs | `common/model/` | `Mode`, `ModeUpsertDTO`, `ModeEndingPausingScenario` |
| Mode picker sheet | `list/widget/` | `ModePickerSheet` for selecting mode in other features |

## CONVENTIONS

- Call `syncLocalDataSource.notifyExternalChange(SyncTable.modes)` after local mutations.
- Use `ModesRepository` for all DB access; avoid raw SQL in bloc/widget.
- App selection uses `InstalledAppsManager` from `pauza_screen_time`; `AppRestrictionManager` for applying restrictions.
- Mode schedules, icons, allowed pauses, and pausing scenarios are in `common/model/`.

## ANTI-PATTERNS

- Do not bypass `ModesRepository` when mutating modes; sync coordination depends on it.
- Do not put SQL or plugin calls in BLoC or widget layer.
- Do not forget to notify sync when modes change locally.
