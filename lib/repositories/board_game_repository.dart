import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/board_game.dart';

class BoardGameRepository {
  BoardGameRepository._();

  static final BoardGameRepository instance = BoardGameRepository._();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<int> insert(BoardGame game) async {
    final db = await _db;
    return db.insert(
      'board_games',
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<bool> exists(String name) async {
    final db = await _db;
    final result = await db.query(
      'board_games',
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [name],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<BoardGame>> getAll() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT bg.*, COUNT(m.id) as timesPlayed
      FROM board_games bg
      LEFT JOIN matches m ON LOWER(bg.name) = LOWER(m.gameName)
      GROUP BY bg.id
      ORDER BY bg.name ASC
    ''');
    return result.map((map) => BoardGame.fromMap(map)).toList();
  }

  Future<List<BoardGame>> search({
    String? name,
    int? minPlayers,
    int? maxPlayers,
    double? minRating,
    double? maxRating,
    int? minDuration,
    int? maxDuration,
    double? minWeight,
    double? maxWeight,
    bool? markForSell,
    bool? markForTrade,
    List<String>? mechanics,
    List<String>? categories,
  }) async {
    final db = await _db;
    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (name != null && name.isNotEmpty) {
      conditions.add('bg.name LIKE ?');
      arguments.add('%$name%');
    }
    if (minPlayers != null) {
      conditions.add('bg.maxPlayers >= ?');
      arguments.add(minPlayers);
    }
    if (maxPlayers != null) {
      conditions.add('bg.minPlayers <= ?');
      arguments.add(maxPlayers);
    }
    if (minRating != null) {
      conditions.add('bg.rating >= ?');
      arguments.add(minRating);
    }
    if (maxRating != null) {
      conditions.add('bg.rating <= ?');
      arguments.add(maxRating);
    }
    if (minDuration != null) {
      conditions.add('bg.duration >= ?');
      arguments.add(minDuration);
    }
    if (maxDuration != null) {
      conditions.add('bg.duration <= ?');
      arguments.add(maxDuration);
    }
    if (minWeight != null) {
      conditions.add('bg.weight >= ?');
      arguments.add(minWeight);
    }
    if (maxWeight != null) {
      conditions.add('bg.weight <= ?');
      arguments.add(maxWeight);
    }
    if (markForSell == true) {
      conditions.add('bg.markForSell = 1');
    }
    if (markForTrade == true) {
      conditions.add('bg.markForTrade = 1');
    }
    if (mechanics != null && mechanics.isNotEmpty) {
      for (final mechanic in mechanics) {
        conditions.add(
          '(bg.mechanics = ? OR bg.mechanics LIKE ? OR bg.mechanics LIKE ? OR bg.mechanics LIKE ?)',
        );
        arguments.addAll([
          mechanic,
          '$mechanic,%',
          '%,$mechanic,%',
          '%,$mechanic',
        ]);
      }
    }
    if (categories != null && categories.isNotEmpty) {
      for (final category in categories) {
        conditions.add(
          '(bg.categories = ? OR bg.categories LIKE ? OR bg.categories LIKE ? OR bg.categories LIKE ?)',
        );
        arguments.addAll([
          category,
          '$category,%',
          '%,$category,%',
          '%,$category',
        ]);
      }
    }

    var whereClause = '';
    if (conditions.isNotEmpty) {
      whereClause = 'WHERE ${conditions.join(' AND ')}';
    }

    final result = await db.rawQuery('''
      SELECT bg.*, COUNT(m.id) as timesPlayed
      FROM board_games bg
      LEFT JOIN matches m ON LOWER(bg.name) = LOWER(m.gameName)
      $whereClause
      GROUP BY bg.id
      ORDER BY bg.name ASC
    ''', arguments.isNotEmpty ? arguments : null);

    return result.map((map) => BoardGame.fromMap(map)).toList();
  }

  Future<int> update(BoardGame game) async {
    final db = await _db;
    return db.update(
      'board_games',
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('board_games', where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getPhotoPath(String gameName) async {
    final db = await _db;
    final result = await db.query(
      'board_games',
      columns: ['photoPath'],
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [gameName],
      limit: 1,
    );
    if (result.isNotEmpty && result.first['photoPath'] != null) {
      return result.first['photoPath'] as String;
    }
    return null;
  }

  Future<BoardGame?> getGameByName(String name) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT bg.*, COUNT(m.id) as timesPlayed
      FROM board_games bg
      LEFT JOIN matches m ON LOWER(bg.name) = LOWER(m.gameName)
      WHERE LOWER(bg.name) = LOWER(?)
      GROUP BY bg.id
      LIMIT 1
    ''', [name]);

    if (result.isNotEmpty) {
      return BoardGame.fromMap(result.first);
    }
    return null;
  }
}
