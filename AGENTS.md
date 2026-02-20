# Instructions for this repository

## Build/lint/test commands

```bash
# Install dependencies
dart pub get

# Run the app
flutter run

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Run a specific test by name
flutter test --name "test name"

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Fix lint issues automatically
flutter fix --apply

# Format code
make format .

# Format with line length
dart format --line-length=80 .

# Generate code (if using build_runner)
dart run build_runner build

# Watch for code generation
flutter pub run build_runner watch

# Generate localizations
flutter gen-l10n
```

## Code style guidelines

### Imports
- Always prefer `package:` imports over relative imports
- ✅ `import 'package:pauza/src/features/modes/common/model/mode.dart';`
- ❌ `import '../modes/common/model/mode.dart';`
- Group imports: Dart/Flutter SDK first, then third-party, then package imports

### File structure & organization
- Follow the preferred layout where each feature lives in its own folder under `lib/src/features/`
- Core utilities go under `lib/src/core/`
- Tests under `test/` should mirror the `lib/` structure

```
lib/
└── src/
    ├── core/
    │   ├── common/
    │   └── utils/
    └── features/
        ├── feature_1/
        │   ├── common/
        │   ├── subfeature_1_a/
        │   │   ├── data/
        │   │   ├── model/
        │   │   └── widget/
        │   ├── subfeature_1_b/
        │   └── subfeature_1_c/
        ├── feature_2/
        └── feature_3/
test/
```

### UI Kit ownership
- This project consumes a local `pauza_ui_kit` package
- Feature-specific widgets should live in their respective feature folders under
  `lib/src/features/...`.
- Reusable widgets/components that can be shared across features should live in
  `pauza_ui_kit`.

### UI Development Guidelines
- **Widget Separation**: Avoid `_buildItem()` helper methods. Break complex UIs into standalone widgets.
- **File Organization**: One widget per file. Do not pile multiple widgets in a single file.
- **Theming**: Use `Theme.of(context)` for all colors and styles. No hard-coded values.
- **Localization**: Use `AppLocalizations` (via context.l10n) for all user-facing strings.

### Naming conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Methods/variables: `camelCase`
- Private members: `_camelCase`
- Constants: `lowerCamelCase` (Dart style, not SCREAMING_SNAKE_CASE)
- Abstract interfaces: `abstract interface class FooRepository`
- Implementations: `class FooRepositoryImpl implements FooRepository`

### Types & formatting
- Use `final` for all variables that don't need reassignment
- Declare return types explicitly (`always_declare_return_types`)
- Use single quotes for strings (`prefer_single_quotes`)
- Omit local variable types when inferred (`omit_local_variable_types`)
- Require trailing commas (`require_trailing_commas`)
- Always put required named parameters first
- Use const constructors where possible
- Avoid unnecessary containers
- Avoid relative lib imports

### Architecture & typing
- Modularize app functionality into features and recursive subfeatures
- Favor strong typing everywhere
- Use DTOs when crossing layer boundaries
- Repository layers need an abstract interface plus a concrete implementation:
  ```dart
  abstract interface class ModesRepository { ... }
  class ModesRepositoryImpl implements ModesRepository { ... }
  ```
- Use Dart 3 pattern clauses (e.g., `if case final ...`) when they improve clarity

### Global feature implementation rules
- Prefer existing domain enums over raw strings.
- Prefer immutable collections (`IList`/`ISet`/`IMap`) over mutable `List`/`Set`/`Map` where practical.
- Use extension types for semantic primitives to avoid raw `int`/`String` leakage.
- Prefer `Duration` in domain models/constants for time quantities instead of raw millisecond/minute integers.
- Keep parsing/formatting as local extensions or typed value methods, not free helpers.
- Keep row mapping in factory constructors (`fromJson`) on DTO/model types; avoid inline map parsing in repositories.
- If model and DTO are structurally identical, unify into a single type and remove duplicates.
- Keep repository-private row/transport DTOs in dedicated `part` files when they are repository-internal.
- Move transformation logic closer to owning DTO/model when it improves cohesion and reduces repository orchestration noise.
- Reuse shared object extensions for common coercions instead of duplicating helpers.

### Enums & models
- Prefer enhanced enums (Dart ≥2.17) when associating data or behavior with enum values
- Domain models must be:
  - Immutable (`@immutable`)
  - Override `toString()`
  - Provide custom equality/`hashCode` logic
- Prefer placing model-related methods on the model itself (not in repositories or helpers)
- If the model comes from another package or cannot be modified, use an extension

### BLoC pattern
- State classes should extend `Equatable`
- Use one of two state patterns:
  1. **Single state class** with `copyWith` for simple blocs:
     ```dart
     final class MyState extends Equatable {
       const MyState({this.isLoading = false, this.error, this.data});
       final bool isLoading;
       final Object? error;
       final Data? data;
       MyState copyWith({...}) => MyState(...);
       @override
       List<Object?> get props => [isLoading, error, data];
     }
     ```
  2. **Sealed class** with subclasses for complex state machines:
     ```dart
     sealed class MyState extends Equatable {
       const MyState();
       @override
       List<Object?> get props => const [];
     }
     final class MyInitial extends MyState { const MyInitial(); }
     final class MyLoading extends MyState { const MyLoading(); }
     final class MyReady extends MyState {
       const MyReady(this.data);
       final Data data;
       @override
       List<Object?> get props => [data];
     }
     final class MyFailure extends MyState {
       const MyFailure(this.error);
       final Object error;
       @override
       List<Object?> get props => [error];
     }
     ```
- Handle errors within try-catch blocks and emit error states
- Keep events and states in separate part files

### Error handling
- Use try-catch blocks in BLoC methods
- Emit appropriate error states rather than throwing
- Handle edge cases explicitly (e.g., empty lists, null checks)

### Localization
- Use the `AppLocalizations` class for all user-facing strings
- Add new strings to `assets/l10n/app_en.arb` first
- Run `flutter gen-l10n` after modifying ARB files
- Generated files are in `lib/src/core/localization/gen/`

### Linting
- Always run `flutter analyze` and fix all issues before finalizing any change
- Key enforced rules (treated as errors):
  - `always_use_package_imports`
  - `avoid_relative_lib_imports`
  - `prefer_single_quotes`
  - `require_trailing_commas`
  - `prefer_final_locals`
  - `prefer_const_constructors`
  - `unnecessary_this`, `unnecessary_new`, `unnecessary_const`
  - `missing_required_param`, `missing_return`
  - `unused_import`, `unused_local_variable`, `unused_element`
  - `annotate_overrides`
  - `always_declare_return_types`
  - `strict-inference: true`, `strict-raw-types: true`

### Widget test stability (important)
- **Avoid `pumpAndSettle()` with continuously animating widgets** (for example chart widgets, repeating animations, indeterminate progress indicators).
- Why: `pumpAndSettle()` waits until there are no scheduled frames; ongoing animations keep scheduling frames forever, so tests hang.
- Prefer bounded pumping for UI assertions:
  - `await tester.pump();`
  - `await tester.pump(const Duration(milliseconds: 200));`
  - Add only the minimum extra pumps needed for the assertion.
- For chart-heavy UIs, prefer disabling animation in test-only config when possible (for example, pass animation duration as `Duration.zero`).
- **Do not `await bloc.close()` while the widget tree still listens to that bloc** (for example when provided via `BlocProvider` in the same test).
- Why: active stream listeners in mounted widgets can keep cleanup from completing and cause stalls/timeouts.
- Preferred cleanup patterns:
  - Register cleanup immediately: `addTearDown(bloc.close);`
  - If manual close is required in-test, unmount first:
    - `await tester.pumpWidget(const SizedBox.shrink());`
    - `await tester.pump();`
    - `await bloc.close();`

### Git workflow
- Never commit secrets or keys
- Run linter and fix all issues before committing
- Generated files (in `lib/src/core/localization/gen/`, `.dart_tool/`, `build/`) should not be committed
