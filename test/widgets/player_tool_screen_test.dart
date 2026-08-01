import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bg_app2/database/database_helper.dart';
import 'package:bg_app2/models/board_game.dart';
import 'package:bg_app2/repositories/board_game_repository.dart';
import 'package:bg_app2/screens/for_sell_games_screen.dart';
import 'package:bg_app2/screens/player_tool_screen.dart';
import 'package:bg_app2/screens/turn_order_tool_screen.dart';

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

  group('PlayerToolScreen Menu Hub Tests', () {
    testWidgets('PlayerToolScreen renders Turn Order and Marketplace tool cards', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(
        home: PlayerToolScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tools'), findsOneWidget);
      expect(find.text('Turn Order'), findsOneWidget);
      expect(find.text('Marketplace'), findsOneWidget);
    });

    testWidgets('Tapping Turn Order navigates to TurnOrderToolScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(
        home: PlayerToolScreen(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Turn Order'));
      await tester.pumpAndSettle();

      expect(find.byType(TurnOrderToolScreen), findsOneWidget);
      expect(find.text('Competitive'), findsOneWidget);
      expect(find.text('Teams'), findsOneWidget);
    });

    testWidgets('ForSellGamesScreen renders empty state when no games marked for sell', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(const MaterialApp(
          home: ForSellGamesScreen(),
        ));
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Marketplace'), findsOneWidget);
      expect(find.text('No games marked for sale'), findsOneWidget);
    });

    testWidgets('ForSellGamesScreen renders games marked for sell in grid', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        final game = BoardGame(
          name: 'Monopoly',
          minPlayers: 2,
          maxPlayers: 6,
          rating: 6.0,
          duration: 120,
          weight: 2.0,
          isOwned: true,
          markForSell: true,
          sellPrice: 15.0,
        );
        await BoardGameRepository.instance.insert(game);

        await tester.pumpWidget(const MaterialApp(
          home: ForSellGamesScreen(),
        ));
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Monopoly'), findsOneWidget);
      expect(find.text('\$15.00'), findsOneWidget);
    });
  });
}
