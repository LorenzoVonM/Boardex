import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/match.dart';

class MatchRepository {
  MatchRepository._();

  static final MatchRepository instance = MatchRepository._();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<String> getCanonicalGameName(String name) async {
    final db = await _db;
    final libResult = await db.query(
      'board_games',
      columns: ['name'],
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [name],
      limit: 1,
    );
    if (libResult.isNotEmpty) {
      return libResult.first['name'] as String;
    }

    final matchResult = await db.rawQuery(
      'SELECT gameName FROM matches WHERE LOWER(gameName) = LOWER(?) LIMIT 1',
      [name],
    );
    if (matchResult.isNotEmpty) {
      return matchResult.first['gameName'] as String;
    }

    return name;
  }

  Future<int> insert(GameMatch match) async {
    final db = await _db;
    final canonicalName = await getCanonicalGameName(match.gameName);
    final normalizedMatch = match.copyWith(gameName: canonicalName);
    return db.insert('matches', normalizedMatch.toMap());
  }

  Future<List<GameMatch>> getAll() async {
    final db = await _db;
    final result = await db.query('matches', orderBy: 'playedAt DESC');
    return result.map((map) => GameMatch.fromMap(map)).toList();
  }

  Future<List<GameMatch>> search({
    String? gameName,
    MatchResult? result,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final db = await _db;
    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (gameName != null && gameName.isNotEmpty) {
      conditions.add('gameName LIKE ?');
      arguments.add('%$gameName%');
    }
    if (result != null) {
      conditions.add('result = ?');
      arguments.add(result.name);
    }
    if (fromDate != null) {
      conditions.add('playedAt >= ?');
      arguments.add(fromDate.toIso8601String());
    }
    if (toDate != null) {
      final endOfDay = DateTime(
        toDate.year,
        toDate.month,
        toDate.day,
        23,
        59,
        59,
      );
      conditions.add('playedAt <= ?');
      arguments.add(endOfDay.toIso8601String());
    }

    String? whereClause;
    if (conditions.isNotEmpty) {
      whereClause = conditions.join(' AND ');
    }

    final results = await db.query(
      'matches',
      where: whereClause,
      whereArgs: arguments.isNotEmpty ? arguments : null,
      orderBy: 'playedAt DESC',
    );

    return results.map((map) => GameMatch.fromMap(map)).toList();
  }

  Future<int> update(GameMatch match) async {
    final db = await _db;
    final canonicalName = await getCanonicalGameName(match.gameName);
    final normalizedMatch = match.copyWith(gameName: canonicalName);
    return db.update(
      'matches',
      normalizedMatch.toMap(),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('matches', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getDistinctGameNames() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT name FROM board_games
      UNION
      SELECT gameName AS name FROM matches
        WHERE LOWER(gameName) NOT IN (SELECT LOWER(name) FROM board_games)
        GROUP BY LOWER(gameName)
      ORDER BY name ASC
    ''');
    return result.map((row) => row['name'] as String).toList();
  }

  Future<List<String>> getGameNamesWithMatchesNotInLibrary() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT MIN(gameName) AS name FROM matches
      WHERE LOWER(gameName) NOT IN (SELECT LOWER(name) FROM board_games)
      GROUP BY LOWER(gameName)
      ORDER BY name ASC
    ''');
    return result.map((row) => row['name'] as String).toList();
  }

  Future<int> getMatchCountByGame(String gameName) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM matches WHERE LOWER(gameName) = LOWER(?)',
      [gameName],
    );
    return result.first['count'] as int;
  }

  Future<List<String>> getDistinctPlayers() async {
    final db = await _db;
    final matches = await db.query('matches', columns: ['players']);
    final playerSet = <String>{};
    for (final row in matches) {
      final playersStr = row['players'] as String?;
      if (playersStr != null && playersStr.isNotEmpty) {
        final decoded = jsonDecode(playersStr);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is String && item.isNotEmpty) {
              playerSet.add(item);
            }
          }
        }
      }
    }
    final sorted = playerSet.toList()..sort();
    return sorted;
  }

  Future<List<GameMatch>> searchForSummary({
    MatchResult? resultFilter,
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? players,
  }) async {
    final db = await _db;
    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (resultFilter != null) {
      conditions.add('result = ?');
      arguments.add(resultFilter.name);
    }
    if (fromDate != null) {
      conditions.add('playedAt >= ?');
      arguments.add(fromDate.toIso8601String());
    }
    if (toDate != null) {
      final endOfDay = DateTime(
        toDate.year,
        toDate.month,
        toDate.day,
        23,
        59,
        59,
      );
      conditions.add('playedAt <= ?');
      arguments.add(endOfDay.toIso8601String());
    }

    String? whereClause;
    if (conditions.isNotEmpty) {
      whereClause = conditions.join(' AND ');
    }

    final results = await db.query(
      'matches',
      where: whereClause,
      whereArgs: arguments.isNotEmpty ? arguments : null,
      orderBy: 'playedAt DESC',
    );

    var matches = results.map((map) => GameMatch.fromMap(map)).toList();
    if (players != null && players.isNotEmpty) {
      matches = matches.where((match) {
        for (final player in players) {
          if (match.players.any(
            (matchPlayer) =>
                matchPlayer.toLowerCase().contains(player.toLowerCase()),
          )) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    return matches;
  }
}
