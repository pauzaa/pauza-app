# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Reference Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run all tests
flutter test --coverage

# Run a single test file
flutter test test/path/to/test_file.dart

# Run a specific test by name
flutter test --name "test name"

# Code generation (l10n, assets, build_runner)
make generate

# Format code (120 char line width)
dart format -l 120 lib/ test/

# Analyze (format check + strict lint)
make analyze

# Auto-fix lint issues
dart fix --apply lib

# Generate localizations only
flutter gen-l10n
```

## Architecture

Flutter mobile app for modes-based app blocking (behavior intervention). Offline-first with SQLite, syncs to pauza-server.

**Stack:** BLoC state management, Helm routing, AppFuse init/config, `pauza_screen_time` plugin for app restrictions, `pauza_ui_kit` local package for shared UI.

**Data flow:** `Widget -> BLoC -> Repository (abstract interface + *Impl) -> DataSource (local SQLite / remote API)`

**DI:** `PauzaDependencies` in `lib/src/core/init/` bootstraps everything. `RootScope` provides app-level BLoCs/repos.

**API client:** Custom `ApiClient` with middleware chain (logger, auth with token refresh, retry) in `lib/src/core/api_client/`.

**Config:** JSON assets (`config/prod.json`, `config/test.json`) loaded via AppFuse.

**Localization:** 4 languages (en, uz, ru, uz-Cyrl). Source ARB: `assets/l10n/app_en.arb`. Access via `context.l10n`.

## Workflow

- Always run `flutter analyze` and fix all lint errors before finishing work on any task

## Code Style & Formatting

- Always use `package:pauza/...` imports, never relative imports for lib/
- Import grouping: Dart/Flutter SDK first, then third-party, then package imports
- Line width: 120 characters
- Single quotes for strings, trailing commas required, `final` for all non-reassigned variables
- `const` constructors where possible
- Explicitly declare return types (`always_declare_return_types`)
- Omit local variable types when inferred (`omit_local_variable_types`)
- Naming: files `snake_case.dart`, classes `PascalCase`, methods/variables `camelCase`, constants `lowerCamelCase`
- Strict analysis: `strict-inference`, `strict-raw-types`, all warnings as errors
- Always run `flutter analyze` and fix all issues before finalizing any change

## Architecture Rules

### Layering
- `Widget -> BLoC -> Repository -> DataSource` - never skip layers
- No business logic in widgets; no HTTP/DB concerns in BLoCs
- Repositories: `abstract interface class FooRepository` + `class FooRepositoryImpl`
- Use DTOs when crossing layer boundaries
- Keep row/transport mapping in `fromJson` factory constructors on DTO/model types, not inline in repositories

### Widgets
- One widget per file; no `_buildItem()` helpers - extract standalone widgets instead
- Colors/styles via `Theme.of(context)`, strings via `context.l10n`
- Feature-specific widgets in their feature folder; reusable widgets in `pauza_ui_kit`

### BLoC
- States extend `Equatable`; events/states in separate `part` files
- Two patterns: single state with `copyWith` (simple) or sealed subclasses (complex state machines)
- Handle errors in try-catch, emit error states rather than throwing

### Models & Types
- Domain models must be immutable (`@immutable`), override `toString()`, provide custom equality/`hashCode`
- Prefer enhanced enums (Dart >= 2.17) when associating data/behavior with enum values
- Prefer domain enums over raw strings
- Prefer `Duration` for time quantities instead of raw int milliseconds/minutes
- Use extension types for semantic primitives to avoid raw `int`/`String` leakage
- Prefer immutable collections (`IList`/`ISet`/`IMap`) over mutable ones
- If model and DTO are structurally identical, unify into a single type
- Place model-related methods on the model itself; use extensions if model is from another package

### Feature Structure
```
features/
  feature_name/
    common/          # shared models, utils
    subfeature_a/
      data/          # data sources, repositories
      model/         # DTOs, domain models
      widget/        # UI
```

## Git & Generated Files

- Never commit secrets (API keys, tokens, `.env`)
- Generated files (`lib/src/core/localization/gen/`, `.dart_tool/`, `build/`) should not be committed

## Testing

- Tests mirror `lib/` structure under `test/`
- Uses `mocktail` for mocking, `bloc_test` for BLoC tests
- **Never use `pumpAndSettle()`** with animating widgets - use bounded `tester.pump(Duration(...))` instead
- **Never `await bloc.close()`** while widget tree listens - use `addTearDown(bloc.close)` instead
- Register fallback values in `test/helpers/register_fallback_values.dart`

## Deeper Documentation

See `AGENTS.md` at root and in subdirectories for detailed conventions, feature catalog, and architecture specifics.
