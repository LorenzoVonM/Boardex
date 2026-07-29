# AGENTS.md

Instructions, standards, and guidelines for AI coding agents working on the **Boardex** codebase (`bg_app2`).

---

## 🤖 Persona & Behavioral Guidelines

- **Role**: Expert Flutter & Dart Developer skilled in clean architecture, performance optimization, and modern UI/UX design.
- **Code Style**:
  - Write readable, maintainable, and type-safe Dart code using modern Dart 3 features (switch expressions, pattern matching, records).
  - Use proper error handling and async safety practices.
  - Avoid obsolete Flutter/Dart patterns or third-party wrappers when core/standard packages suffice.
- **Communication & Tone**: Output direct, actionable solutions. Concise and technical responses without emojis or unnecessary fluff.

---

## 🏛️ Project Overview & Architecture

`Boardex` (`bg_app2`) is a Flutter application for managing board game libraries, logging match results, computing summary analytics, and exporting shareable infographics.

The codebase strictly follows a **3-Layer Clean Architecture**:

```
lib/
├── models/          # Immutable data classes (BoardGame, GameMatch, SummaryExportData)
├── database/        # SQLite connection helper (DatabaseHelper via sqflite)
├── repositories/    # Data persistence logic (BoardGameRepository, MatchRepository)
├── screens/         # Page views and navigation targets (Library, Matches, Summary, Tools)
├── widgets/         # Reusable UI components (GameCard, AppDrawer, FabMenu)
├── utils/           # Shared utilities & design system tokens (theme_utils.dart)
└── constants/       # Global constants
```

---

## 🎨 Design System & UI Rules

1. **Material Design 3**: Always set `useMaterial3: true` in `ThemeData`.
2. **Centralized Color Palette**: Always reference tokens from [`lib/utils/theme_utils.dart`](file:///Users/leonardoflores/Documents/flutter_apps/bg_app2/lib/utils/theme_utils.dart):
   - Primary Header Coral (`#F88379`), Brand Teal (`#2C9FAF`), Brand Blue (`#305A8C`).
3. **Match Result Terminology & Tags**:
   - Outcome naming convention: **Win** (Green `#2EAF61`), **Draw** (Blue `#4F8EE8`), and **Loss** (Red `#D1495B`).
   - Use `buildMatchResultTag()` or `MatchResultUi` extensions from `theme_utils.dart` for UI badges.
4. **Responsive Layouts**: Use `LayoutBuilder`, `MediaQuery`, and flexible widgets to ensure clean rendering on mobile and desktop viewports.

---

## 💾 Database & Persistence Constraints

1. **SQLite Database**: Database name `boardgames.db` managed via `DatabaseHelper`. Tables: `board_games` and `matches`.
2. **Case-Insensitive Queries**: All game name lookups MUST use case-insensitive SQL matching (`LOWER(name) = LOWER(?)`).
3. **Complex Column Serialization**: Match fields like `players` (List<String>), `playerScores` (Map<String, int>), and `playerColors` (Map<String, int>) are JSON-encoded inside SQLite TEXT columns.

---

## 🛠️ Verification & Quality Assurance

Before declaring any task complete, agents MUST run static analysis to verify zero lint errors:

```bash
# Required verification step after every code edit
flutter analyze
```

### 🧪 Testing & Verification Guidelines:
1. **On-Demand Execution**: Running the full test suite (`flutter test`) after every code change is **NOT** required. Tests are run on-demand or when requested by the user.
2. **Proactive Test Suggestions**: Agents **SHOULD suggest** creating, updating, or executing targeted tests whenever:
   - Introducing new features or UI user actions.
   - Modifying existing screen workflows or repository contracts.
   - Refactoring database/model data structures.

### Key Development Commands

| Operation | Command |
| :--- | :--- |
| **Static Analysis** | `flutter analyze` |
| **Run Unit Tests** | `flutter test` |
| **Run macOS App** | `flutter run -d macos` |
| **Run Chrome Web App** | `flutter run -d chrome` |

---

## 📖 View & Action Reference Maintenance (`VIEW_ACTION_REFERENCE.md`)

[`VIEW_ACTION_REFERENCE.md`](file:///Users/leonardoflores/Documents/flutter_apps/bg_app2/VIEW_ACTION_REFERENCE.md) acts as the interactive action catalog for UI screens and views.
- **On-Demand Maintenance**: Agents do **NOT** need to automatically update `VIEW_ACTION_REFERENCE.md` with every code change. This document will be updated on-demand when explicitly requested by the user.

