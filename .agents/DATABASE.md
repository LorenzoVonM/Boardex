# Database

## Connection

Singleton: `DatabaseHelper.instance.database` → returns a `sqflite` `Database`.
File: `boardgames.db`, current version: **6**.
Migration strategy: **destructive** — `_resetDB` drops and recreates all tables on version change. Do not attempt incremental migrations; bump the version and update `_createDB`.

## Tables

### `board_games`
| Column | Type | Notes |
|---|---|---|
| `id` | `INTEGER PK AUTOINCREMENT` | |
| `name` | `TEXT NOT NULL UNIQUE COLLATE NOCASE` | Case-insensitive unique constraint at DB level |
| `minPlayers` | `INTEGER` | |
| `maxPlayers` | `INTEGER` | |
| `rating` | `REAL` | 0.0–10.0 |
| `duration` | `INTEGER` | Minutes |
| `weight` | `REAL DEFAULT 2.5` | 0.0–5.0 difficulty |
| `isOwned` | `INTEGER DEFAULT 0` | Boolean (0/1) |
| `markForSell` | `INTEGER DEFAULT 0` | Boolean (0/1) |
| `markForTrade` | `INTEGER DEFAULT 0` | Boolean (0/1) |
| `sellPrice` | `REAL` | Nullable |
| `photoPath` | `TEXT` | Nullable |
| `thumbnailPath` | `TEXT` | Nullable |
| `mechanics` | `TEXT DEFAULT ''` | Comma-separated string |
| `categories` | `TEXT DEFAULT ''` | Comma-separated string |

### `matches`
| Column | Type | Notes |
|---|---|---|
| `id` | `INTEGER PK AUTOINCREMENT` | |
| `gameName` | `TEXT NOT NULL` | Indexed via `idx_matches_gameName` |
| `duration` | `INTEGER` | Minutes |
| `result` | `TEXT` | Stored as enum name: `won`, `tie`, `lost` |
| `winner` | `TEXT` | Nullable player name |
| `playerScores` | `TEXT` | **JSON**: `Map<String, int>` — nullable when empty |
| `playerColors` | `TEXT` | **JSON**: `Map<String, int>` ARGB values — nullable when empty |
| `players` | `TEXT` | **JSON**: `List<String>` — nullable when empty |
| `photoPath` | `TEXT` | Nullable |
| `thumbnailPath` | `TEXT` | Nullable |
| `useLibraryPhoto` | `INTEGER DEFAULT 0` | Boolean (0/1) |
| `playedAt` | `TEXT` | ISO 8601 string |

## JSON Serialization Rules

These columns are JSON-encoded TEXT. Encode with `jsonEncode()`, decode with `jsonDecode()`. Store `null` when the collection is empty (not an empty JSON string).

```dart
// encoding
'playerScores': playerScores.isNotEmpty ? jsonEncode(playerScores) : null,

// decoding
playerScores: map['playerScores'] != null
    ? Map<String, int>.from(jsonDecode(map['playerScores'] as String))
    : {},
```

## Case-Insensitive Lookup Rule

All name-based queries MUST use `LOWER()`:

```dart
where: 'LOWER(gameName) = LOWER(?)',
whereArgs: [name],
```

Never use `=` alone for name comparisons.
