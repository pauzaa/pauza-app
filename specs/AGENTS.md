# Specifications
> See [/AGENTS.md](/AGENTS.md) for project-wide rules.

## OVERVIEW

`specs/` contains product and technical specifications. These describe the product vision, architecture, and implementation guidelines that the codebase should follow.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Product spec (modes, sessions, features) | `specs/specifications.md` | v1 product spec: intervention engine, NFC/PIN, scheduling, analytics, AI, backend, platform, security, acceptance criteria |
| Technical spec | `specs/technical_details.md` | BLoC, Helm, AppFuse, localization, theming, `pauza_screen_time`, platform constraints, collections, SQLite, dependencies |

## CONVENTIONS

- New features should align with `specifications.md` scope.
- Technical decisions should reference `technical_details.md` where applicable.
- Update specs when changing architecture or product scope.

## ANTI-PATTERNS

- Do not implement features out of scope without updating specs.
- Do not bypass documented architectural patterns without spec update.
