# Architecture

## 3-Layer Structure

```
lib/
├── models/          # Immutable data classes — no logic, no DB access
├── database/        # DatabaseHelper singleton — connection and schema only
├── repositories/    # All DB read/write logic — one class per model
├── screens/         # Full-page views — StatefulWidget + setState
├── widgets/         # Reusable UI components
├── utils/           # Shared utilities and design system tokens
└── constants/       # Global app-wide constants
```

## State Management

**Pattern: StatefulWidget + setState + singleton repositories.**

There is no state management library (no Provider, Riverpod, Bloc, or GetX). Screens own their local state via `_field` instance variables and call `setState()` directly. All persistence goes through the repository layer.

```dart
// correct pattern
class _MyScreenState extends State<MyScreen> {
  List<Item> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await MyRepository.instance.getAll();
      if (!mounted) return;
      setState(() { _items = items; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
```

Always check `if (!mounted) return;` before any `setState` following an `await`.

## Navigation

**Pattern: `Navigator.push` / `Navigator.pop` with `MaterialPageRoute`. No named routes, no GoRouter.**

Screens return a `bool` result to signal whether a reload is needed:

```dart
// push with result
final result = await Navigator.push<bool>(
  context,
  MaterialPageRoute(builder: (context) => const SomeScreen()),
);
if (result == true) _reload();

// pop with result
Navigator.pop(context, true);
```

## Repository Pattern

Repositories are **private-constructor singletons**. All DB access goes through them, never directly from a screen.

```dart
class MyRepository {
  MyRepository._();
  static final MyRepository instance = MyRepository._();
  Future<Database> get _db async => DatabaseHelper.instance.database;
  // methods...
}
```

## Key File Locations

| Concern | File |
|---|---|
| Color tokens / design utilities | `lib/utils/theme_utils.dart` |
| DB connection & schema | `lib/database/database_helper.dart` |
| Match result tags & color extensions | `lib/utils/theme_utils.dart` (`buildMatchResultTag`, `MatchResultUi`) |
| UI action catalog | `VIEW_ACTION_REFERENCE.md` |
