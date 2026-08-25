# AGENTS.md

Entry point for AI coding agents working on **Boardex** (`bg_app2`) — a Flutter app for managing board game libraries, logging matches, computing analytics, and exporting infographics.

Read this file first, then load the `.agents/` files relevant to your task.

---

## Persona & Behavioral Guidelines

- **Role**: Expert Flutter & Dart developer. Clean architecture, performance, modern UI/UX.
- **Code style**: Readable, type-safe Dart 3 (switch expressions, pattern matching, records). Proper async safety. No obsolete patterns or unnecessary third-party wrappers.
- **Tone**: Direct, actionable, concise. No emojis or filler.

---

## Context Files — Load What You Need

| File | Covers | Load when... |
|---|---|---|
| `.agents/ARCHITECTURE.md` | Layer structure, state management, navigation pattern, repository pattern | Starting any new screen, widget, or repository work |
| `.agents/CONVENTIONS.md` | Screen boilerplate, existing utilities, anti-patterns, Dart style | Writing or modifying any Dart file |
| `.agents/DESIGN_SYSTEM.md` | Color tokens, match result tags, responsive layout rules | Touching any UI code |
| `.agents/DATABASE.md` | Tables, columns, JSON serialization, case-insensitive rule, migrations | Modifying models, repositories, or schema |
| `.agents/DECISIONS.md` | Why key technology choices were made | Before suggesting an alternative library or pattern |
| `VIEW_ACTION_REFERENCE.md` | Full catalog of screens and their user actions | Before adding a new user action or screen |

---

## Non-Negotiable Rules

1. **Always run `flutter analyze` before declaring a task complete.** Zero lint errors required.
2. **All colors via `AppColors` in `lib/utils/theme_utils.dart` — never use inline hex literals or `Color(0xFF...)` constructors in UI code. If a token doesn't exist, add it to `AppColors` first.**
3. **All game/match name DB lookups must use `LOWER(x) = LOWER(?)`.**
4. **Update `VIEW_ACTION_REFERENCE.md` whenever a screen is added, modified, or removed** — new actions, renamed actions, description changes, and deleted screens must all be reflected immediately. Use the `view_verb_target` convention for action names.
5. **`flutter test` is on-demand only** — do not run it automatically. Do suggest targeted tests when introducing new features, modifying repository contracts, or refactoring data structures.

---

## Key Commands

| Operation | Command |
|---|---|
| Static analysis | `flutter analyze` |
| Run unit tests | `flutter test` |
| Run macOS | `flutter run -d macos` |
| Run Chrome | `flutter run -d chrome` |

---

## View & Action Reference

`VIEW_ACTION_REFERENCE.md` is the UI action catalog. It is updated on-demand — agents do not need to update it automatically after every change.

