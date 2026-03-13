# pauza_ui_kit – Shared UI Components
> See [/AGENTS.md](/AGENTS.md) for project-wide rules.

## OVERVIEW

`pauza_ui_kit` is a local Flutter package providing themes, foundations (spacing, sizes, radii), and reusable base components. It is consumed by the main app via `workspace:` in `pubspec.yaml`. Feature-specific widgets stay in feature folders; shared components belong here.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Theme, colors, typography | `lib/src/theme/` | `PauzaTheme`, `PauzaColorScheme`, `PauzaTextTheme` |
| Foundations (spacing, sizes) | `lib/src/foundations/` | `PauzaSpacing`, `PauzaCornerRadius`, form/icon/avatar sizes |
| Buttons | `lib/src/base_components/buttons/` | `PauzaFilledButton`, `PauzaOutlinedButton`, `PauzaTextButton`, etc. |
| Inputs | `lib/src/base_components/inputs/` | `PauzaTextFormField`, `PauzaPinCodeField`, `PauzaInputDecoration` |
| List tiles, dialogs | `lib/src/base_components/list_tiles/`, `dialogs/` | `PauzaListTileCard`, `PauzaAlertDialog` |
| Selectors | `lib/src/base_components/selectors/` | `PauzaFilterChip`, `PauzaDateRangePickerCard`, `showCupertinoTimePicker` |
| App bars, bottom nav | `lib/src/base_components/app_bars/`, `bottom_navigation_bar/` | `PauzaDashboardAppBar`, `PauzaBottomNavigationBar` |
| Main export | `lib/pauza_ui_kit.dart` | Barrel; import `package:pauza_ui_kit/pauza_ui_kit.dart` |

## CONVENTIONS

- Use `Theme.of(context)` for all styling; no hard-coded values.
- One widget per file; export via `export.dart` in each subfolder.
- Theme setup: `PauzaTheme.light` / `PauzaTheme.dark` in main app `PauzaApp`.
- Tests mirror structure: `test/base_components/<type>/<widget>_test.dart`.

## ANTI-PATTERNS

- Do not add feature-specific logic to UI kit components.
- Do not hardcode colors or dimensions; use theme and foundations.
- Do not create new `_Fake` or `_Noop` test helpers; use shared helpers.

## TESTING

```bash
flutter test local_packages/pauza_ui_kit/
flutter test local_packages/pauza_ui_kit/test/base_components/buttons/pauza_buttons_test.dart
```
