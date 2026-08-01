import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bg_app2/database/database_helper.dart';
import 'package:bg_app2/models/board_game.dart';
import 'package:bg_app2/models/match.dart';
import 'package:bg_app2/screens/game_detail_screen.dart';
import 'package:bg_app2/screens/match_detail_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('matches');
    await db.delete('board_games');
  });

  final testGame = BoardGame(
    id: 1,
    name: 'Catan',
    minPlayers: 3,
    maxPlayers: 4,
    rating: 8.5,
    duration: 90,
    weight: 2.3,
    isOwned: true,
    markForSell: false,
    markForTrade: false,
    mechanics: const ['Dice Rolling', 'Trading'],
    categories: const ['Strategy', 'Economic'],
  );

  final testMatch = GameMatch(
    id: 1,
    gameName: 'Catan',
    playedAt: DateTime(2026, 5, 20),
    duration: 75,
    result: MatchResult.won,
    players: const ['Alice', 'Bob'],
  );

  group('Details Screens Widget Tests', () {
    testWidgets('GameDetailScreen renders game details and floating edit/delete icons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          home: GameDetailScreen(game: testGame),
        ));
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Game Details'), findsWidgets);
      expect(find.text('Catan'), findsOneWidget);
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('MatchDetailScreen renders match details and floating edit/delete icons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          home: MatchDetailScreen(match: testMatch),
        ));
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Match Details'), findsWidgets);
      expect(find.text('Catan'), findsOneWidget);
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });
  });
}
