import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('boardgames.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _resetDB,
      onDowngrade: _resetDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE board_games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE COLLATE NOCASE,
        minPlayers INTEGER NOT NULL,
        maxPlayers INTEGER NOT NULL,
        rating REAL NOT NULL,
        duration INTEGER NOT NULL,
        weight REAL NOT NULL DEFAULT 2.5,
        isOwned INTEGER NOT NULL DEFAULT 0,
        markForSell INTEGER NOT NULL DEFAULT 0,
        markForTrade INTEGER NOT NULL DEFAULT 0,
        sellPrice REAL,
        photoPath TEXT,
        mechanics TEXT NOT NULL DEFAULT '',
        categories TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gameName TEXT NOT NULL,
        duration INTEGER NOT NULL,
        result TEXT NOT NULL,
        winner TEXT,
        playerScores TEXT,
        playerColors TEXT,
        photoPath TEXT,
        useLibraryPhoto INTEGER NOT NULL DEFAULT 0,
        playedAt TEXT NOT NULL,
        players TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_matches_gameName ON matches(gameName)');
  }

  Future<void> _resetDB(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP INDEX IF EXISTS idx_matches_gameName');
    await db.execute('DROP TABLE IF EXISTS matches');
    await db.execute('DROP TABLE IF EXISTS board_games');
    await _createDB(db, newVersion);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
