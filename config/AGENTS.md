# Environment Configuration
> See [/AGENTS.md](/AGENTS.md) for project-wide rules.

## OVERVIEW

`config/` holds JSON environment configuration files. They are declared under `assets:` in `pubspec.yaml` and loaded via AppFuse `JsonAssetConfig`. `ProdConfig` and `TestConfig` map to `Assets.config.prod` and `Assets.config.test` (flutter_gen).

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Production config | `config/prod.json` | `APP_NAME`, `API_BASE_URL`, `INTERNET_PROBE_URL` (empty for prod) |
| Test / local dev config | `config/test.json` | Same fields; API points at localhost |
| Config model | `lib/src/core/init/config.dart` | `PauzaConfig`, `ProdConfig`, `TestConfig` |
| Config selection | `lib/src/app/pauza_app.dart` | `PauzaApp.configs` lists configs for AppFuse |

## CONVENTIONS

- Add new config files to `config/` and register in `PauzaApp.configs` if needed.
- Use `PauzaConfig` extensions for new fields; keep defaults in `config.dart`.
- `internetProbeUrl` is optional; falls back to API base URL or google.com.

## ANTI-PATTERNS

- Do not commit secrets or API keys in config JSON.
- Do not parse env outside `init/`; config is asset-based, not `.env`.
