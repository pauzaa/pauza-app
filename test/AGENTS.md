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
