import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bg_app2/database/database_helper.dart';
import 'package:bg_app2/models/board_game.dart';
import 'package:bg_app2/models/match.dart';
import 'package:bg_app2/repositories/board_game_repository.dart';
import 'package:bg_app2/repositories/match_repository.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for in-memory SQLite database testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('matches');
    await db.delete('board_games');
  });

  group('MatchRepository - Canonical Names & Suggestions Tests', () {
    test('getCanonicalGameName resolves exact casing from library game name', () async {
      await BoardGameRepository.instance.insert(
        BoardGame(
          name: 'Catan',
          minPlayers: 3,
          maxPlayers: 4,
          rating: 8.0,
          duration: 60,
        ),
      );

      // Typing "catan" or "CATAN" should return "Catan"
      final canonical1 = await MatchRepository.instance.getCanonicalGameName('catan');
      final canonical2 = await MatchRepository.instance.getCanonicalGameName('CATAN');

      expect(canonical1, 'Catan');
      expect(canonical2, 'Catan');
    });

    test('getCanonicalGameName falls back to match history casing if not in library', () async {
      await MatchRepository.instance.insert(
        GameMatch(
          gameName: 'Brass: Birmingham',
          duration: 120,
          result: MatchResult.won,
          playedAt: DateTime.now(),
        ),
      );

      final canonical = await MatchRepository.instance.getCanonicalGameName('brass: birmingham');
      expect(canonical, 'Brass: Birmingham');
    });

    test('getDistinctGameNames combines library games and unregistered matches alphabetically', () async {
      await BoardGameRepository.instance.insert(
        BoardGame(name: 'Azul', minPlayers: 2, maxPlayers: 4, rating: 8.0, duration: 30),
      );
      await BoardGameRepository.instance.insert(
        BoardGame(name: 'Dixit', minPlayers: 3, maxPlayers: 6, rating: 7.5, duration: 30),
      );

      // Match for a game in library
      await MatchRepository.instance.insert(
        GameMatch(gameName: 'azul', duration: 30, result: MatchResult.won, playedAt: DateTime.now()),
      );
      // Match for a game NOT in library
      await MatchRepository.instance.insert(
        GameMatch(gameName: 'Catan', duration: 60, result: MatchResult.lost, playedAt: DateTime.now()),
      );

      final distinctNames = await MatchRepository.instance.getDistinctGameNames();

      expect(distinctNames, ['Azul', 'Catan', 'Dixit']);
    });

    test('getGameNamesWithMatchesNotInLibrary returns only games played that are not in library', () async {
      // Library has "Pandemic"
      await BoardGameRepository.instance.insert(
        BoardGame(name: 'Pandemic', minPlayers: 2, maxPlayers: 4, rating: 8.0, duration: 45),
      );

      // Matches for "Pandemic" (in library) and "Splendor" (not in library)
      await MatchRepository.instance.insert(
        GameMatch(gameName: 'Pandemic', duration: 45, result: MatchResult.won, playedAt: DateTime.now()),
      );
      await MatchRepository.instance.insert(
        GameMatch(gameName: 'Splendor', duration: 30, result: MatchResult.tie, playedAt: DateTime.now()),
      );

      final suggestions = await MatchRepository.instance.getGameNamesWithMatchesNotInLibrary();

      expect(suggestions, ['Splendor']);
    });
  });

  group('MatchRepository - Player Extraction Tests', () {
    test('getDistinctPlayers extracts, deduplicates, and sorts players from JSON match records', () async {
      await MatchRepository.instance.insert(
        GameMatch(
          gameName: 'Catan',
          duration: 60,
          result: MatchResult.won,
          players: ['Charlie', 'Alice'],
          playedAt: DateTime.now(),
        ),
      );

      await MatchRepository.instance.insert(
        GameMatch(
          gameName: 'Azul',
          duration: 30,
          result: MatchResult.lost,
          players: ['Bob', 'Alice'],
          playedAt: DateTime.now(),
        ),
      );

      final players = await MatchRepository.instance.getDistinctPlayers();

      expect(players, ['Alice', 'Bob', 'Charlie']);
    });
  });

  group('MatchRepository - Search & Insertion Tests', () {
    test('insert normalizes game name casing to canonical name', () async {
      await BoardGameRepository.instance.insert(
        BoardGame(name: 'Scythe', minPlayers: 1, maxPlayers: 5, rating: 8.5, duration: 115),
      );

      final matchId = await MatchRepository.instance.insert(
        GameMatch(
          gameName: 'scythe', // lowercase input
          duration: 90,
          result: MatchResult.won,
          playedAt: DateTime.now(),
        ),
      );

      final matches = await MatchRepository.instance.getAll();
      expect(matches.first.id, matchId);
      expect(matches.first.gameName, 'Scythe'); // Normalized canonical name
    });

    test('search filters matches by result outcome and game name', () async {
      final now = DateTime.now();
      await MatchRepository.instance.insert(
        GameMatch(gameName: 'Catan', duration: 60, result: MatchResult.won, playedAt: now),
      );
      await MatchRepository.instance.insert(
        GameMatch(gameName: 'Catan', duration: 60, result: MatchResult.lost, playedAt: now),
      );
      await MatchRepository.instance.insert(
        GameMatch(gameName: 'Azul', duration: 30, result: MatchResult.won, playedAt: now),
      );

      final wonCatan = await MatchRepository.instance.search(
        gameName: 'Catan',
        result: MatchResult.won,
      );

      expect(wonCatan.length, 1);
      expect(wonCatan.first.gameName, 'Catan');
      expect(wonCatan.first.result, MatchResult.won);
    });
  });
}
