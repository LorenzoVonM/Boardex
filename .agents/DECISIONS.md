# Decisions

Captures the *why* behind key technical choices. Before suggesting an alternative technology, read this file.

---

## sqflite over Drift / Isar / Hive

**Choice**: `sqflite` with raw SQL.

**Reason**: Direct SQL control with no codegen overhead. The schema is simple (two tables), and raw queries are easier to reason about for this app's scale. Drift and Isar require `build_runner` and add complexity that isn't justified here.

---

## StatefulWidget + setState over Provider / Riverpod / Bloc

**Choice**: Each screen manages its own state with `setState`. No state management framework.

**Reason**: This is a single-user, local-first app with no cross-screen shared state that would justify a reactive layer. `setState` + singleton repositories is the simplest model that works and keeps the dependency surface minimal.

---

## JSON in TEXT columns over normalized tables

**Choice**: `players`, `playerScores`, and `playerColors` are stored as JSON-encoded TEXT.

**Reason**: Player lists are variable-length and per-match. Normalizing them into a separate table would require joins on every match read and migrations when the shape changes. JSON in TEXT trades query-time flexibility for write simplicity, which is the right call for a personal app with no reporting that queries across players.

---

## Navigator.push over GoRouter / auto_route

**Choice**: Imperative `Navigator.push<bool>` with `MaterialPageRoute`.

**Reason**: The app has no deep linking, no web URL routing, and no complex navigation graph. Named routes or a routing package would add boilerplate with no benefit at this scale.

---

## Destructive migration (_resetDB)

**Choice**: Schema version bump drops and recreates all tables.

**Reason**: Local personal app, single device, no sync. Incremental migrations are not worth maintaining. If the schema changes, the developer accepts re-entering data during development. Ship-time data is preserved by incrementing the version only when absolutely necessary.

---

## VIEW_ACTION_REFERENCE.md action naming convention

**Choice**: `view_verb_target` format (e.g., `library_open_add_game`).

**Reason**: Prefixing actions with the view name makes it unambiguous which screen owns an action, even when the same verb/target pair exists across multiple screens. It also makes search/grep across the reference file reliable.
