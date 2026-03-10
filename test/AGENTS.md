# Test Folder Instructions

These rules apply to files under `test/`.
They complement the repository root `AGENTS.md`.

## Widget test stability

- Avoid `pumpAndSettle()` when the widget tree may contain ongoing animations:
  - chart widgets
  - indeterminate progress indicators
  - repeating animation controllers
- Why: `pumpAndSettle()` waits for no scheduled frames; continuously animated widgets keep scheduling frames and tests can hang.

Use bounded pumping instead:

```dart
await tester.pump();
await tester.pump(const Duration(milliseconds: 200));
```

Only add as many pumps as needed for the assertion.

## Shared test helpers

- Prefer importing shared helpers through:

```dart
import '../helpers/helpers.dart';
```

- Use `tester.pumpApp(...)` for widget tests instead of creating custom test app wrappers.
- `pumpApp` accepts:
  - `theme`
  - `surfaceSize`
  - `providers: List<Widget>`
- When passing `providers`, only pass `BlocProvider` widgets. `pumpApp` wraps them with `MultiBlocProvider`.
- If one `pumpApp` call uses a custom `surfaceSize`, later `pumpApp` calls in the same test can omit `surfaceSize`; the helper resets back to the default test surface automatically.

## Mocktail fallback values

- Prefer `setUpAll(registerTestFallbackValues);` in tests that use mocktail fallback registration.
- Do not register common fallback values ad hoc inside individual test files when the shared helper already covers them.
- The shared fallback helper currently covers:
  - `Duration`
  - `void Function()`
  - `Uint8List`
  - `CachedUserProfile`
  - `ModeUpsertDTO`
  - `NfcChipIdentifier`
- If a new fallback type is needed across multiple tests, add it to `test/helpers/register_fallback_values.dart` and use the shared helper rather than repeating `registerFallbackValue(...)` in each file.

## BLoC lifecycle in widget tests

- Do not `await bloc.close()` while the widget tree is still mounted and listening to that bloc.
- Prefer:

```dart
addTearDown(bloc.close);
```

- If you must close manually in test body, unmount first:

```dart
await tester.pumpWidget(const SizedBox.shrink());
await tester.pump();
await bloc.close();
```

## Chart widgets in tests

- If possible, expose animation duration as an injectable parameter and set it to `Duration.zero` in tests.
- Keep chart assertions structural (widget presence, labels, state transitions), not frame-perfect animation assertions.

## Running tests

- Prefer running focused tests while iterating:

```bash
flutter test test/path/to/file_test.dart
flutter test --plain-name "specific case"
```

- Run `flutter analyze` after test code changes.

## Test helper naming

- Do not introduce new `_Fake`, `_Noop`, or `_TestApp` helper classes under `test/`.
- Prefer descriptive helper names without the underscore prefix, or use the shared mocks/fixtures/helpers when they already fit.
