# Conventions

## Screen Boilerplate

Every screen is a `StatefulWidget`. Load data in `initState`. Use `_isLoading` guard. Always check `mounted` before `setState` after async work.

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<Item> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final items = await MyRepository.instance.getAll();
      if (!mounted) return;
      setState(() { _items = items; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
```

## Existing Utilities — Use Before Creating New

All live in `lib/utils/theme_utils.dart`. Do not re-implement these:

| Utility | What it does |
|---|---|
| `AppColors` | All color tokens (brand, metric, result, weight, rating) |
| `buildMatchResultTag(result, {size, uppercase})` | Renders Win/Draw/Loss pill badge |
| `MatchResultUi` extension on `MatchResult` | `.color`, `.icon`, `.label` per result |
| `getWeightColor(double)` | Maps weight 0–5 to a difficulty color |
| `getRatingColor(double)` | Maps rating 0–10 to a quality color |

## Adding a New Screen

1. Create `lib/screens/my_screen.dart` as `StatefulWidget`.
2. **Update `VIEW_ACTION_REFERENCE.md`** — add a new section for the screen following the existing format (Description + Actions list). Name every user-triggerable action using `view_verb_target`.
3. Navigate to it via `Navigator.push<bool>(...)`.


## Adding a New Repository Method

Place it in the relevant `lib/repositories/` file. Access the DB via `await _db` (the getter that returns `DatabaseHelper.instance.database`). Use the LOWER() pattern for any name lookup:

```dart
where: 'LOWER(name) = LOWER(?)',
whereArgs: [input],
```

## Anti-Patterns — Do Not Introduce

- No `Provider`, `Riverpod`, `Bloc`, or `GetX` — state lives in `StatefulWidget`.
- No `GoRouter` or named routes — use `Navigator.push` directly.
- No `Drift`, `Isar`, or other ORM — use `sqflite` with raw SQL.
- No codegen (`build_runner`) unless already in `pubspec.yaml`.
- Do not call `DatabaseHelper` directly from screens — always go through a repository.
- No over-engineering: only make changes that are directly requested or clearly necessary. Do not add features, helpers, abstractions, extra sections, or "improvements" beyond the scope of the task.

## Dart Style

- Use Dart 3 features where natural: switch expressions, pattern matching, records.
- Prefer `const` constructors.
- Private state fields: `_camelCase`.
- Keep `build()` lean — extract named methods (`_buildGrid()`, `_buildEmptyState()`) for any non-trivial subtrees.
