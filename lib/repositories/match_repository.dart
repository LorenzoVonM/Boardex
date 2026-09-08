import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/match.dart';
import '../utils/image_utils.dart';

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
    var normalizedMatch = match.copyWith(gameName: canonicalName);
    if (normalizedMatch.photoPath != null &&
        normalizedMatch.thumbnailPath == null) {
      final thumb = await ImageUtils.generateThumbnail(
        normalizedMatch.photoPath!,
      );
      normalizedMatch = normalizedMatch.copyWith(thumbnailPath: thumb);
    }
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

    final results = await db.query(
      'matches',
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: arguments.isNotEmpty ? arguments : null,
      orderBy: 'playedAt DESC',
    );

    return results.map((map) => GameMatch.fromMap(map)).toList();
  }

  Future<int> update(GameMatch match) async {
    final db = await _db;
    final canonicalName = await getCanonicalGameName(match.gameName);
    var normalizedMatch = match.copyWith(gameName: canonicalName);
    if (normalizedMatch.photoPath != null &&
        normalizedMatch.thumbnailPath == null) {
      final thumb = await ImageUtils.generateThumbnail(
        normalizedMatch.photoPath!,
      );
      normalizedMatch = normalizedMatch.copyWith(thumbnailPath: thumb);
    }
    return db.update(
      'matches',
      normalizedMatch.toMap(),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    final rows = await db.query(
      'matches',
      columns: ['photoPath', 'thumbnailPath'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    final result = await db.delete('matches', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      await ImageUtils.deletePhotoFiles(
        rows.first['photoPath'] as String?,
        rows.first['thumbnailPath'] as String?,
      );
    }
    return result;
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

  /// Returns a map of 'yyyy-MM-dd' → match count for every day that has matches,
  /// across all games and with no filter applied.
  Future<Map<String, int>> getAllMatchCountsByDay() async {
    final db = await _db;
    final rows = await db.query('matches', columns: ['playedAt']);
    final Map<String, int> counts = {};
    for (final row in rows) {
      final dateStr = row['playedAt'] as String?;
      if (dateStr != null && dateStr.length >= 10) {
        final key = dateStr.substring(0, 10);
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Returns up to [limit] deduplicated (savePath, thumbPath) pairs for
  /// matches of [gameName] that have their own custom photo (not library refs).
  Future<List<({String savePath, String? thumbPath})>>
  getRecentMatchPhotosForGame(String gameName, {int limit = 10}) async {
    final db = await _db;
    final rows = await db.query(
      'matches',
      columns: ['photoPath', 'thumbnailPath'],
      where:
          'LOWER(gameName) = LOWER(?) AND photoPath IS NOT NULL AND useLibraryPhoto = 0',
      whereArgs: [gameName],
      orderBy: 'playedAt DESC',
      limit: limit * 2, // overfetch to account for deduplication
    );
    final seen = <String>{};
    final result = <({String savePath, String? thumbPath})>[];
    for (final row in rows) {
      final path = row['photoPath'] as String;
      if (seen.add(path) && result.length < limit) {
        result.add((
          savePath: path,
          thumbPath: row['thumbnailPath'] as String?,
        ));
      }
    }
    return result;
  }

  Future<DateTime?> getLastPlayedDate(String gameName) async {
    final db = await _db;
    final result = await db.query(
      'matches',
      columns: ['playedAt'],
      where: 'LOWER(gameName) = LOWER(?)',
      whereArgs: [gameName],
      orderBy: 'playedAt DESC',
      limit: 1,
    );
    if (result.isNotEmpty && result.first['playedAt'] != null) {
      return DateTime.tryParse(result.first['playedAt'] as String);
    }
    return null;
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
