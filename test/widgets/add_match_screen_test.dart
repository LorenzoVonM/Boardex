import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bg_app2/database/database_helper.dart';
import 'package:bg_app2/models/match.dart';
import 'package:bg_app2/screens/add_match_screen.dart';

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

  Widget buildTestWidget({GameMatch? matchToEdit}) {
    return MaterialApp(
      home: AddMatchScreen(matchToEdit: matchToEdit),
    );
  }

  group('AddMatchScreen Widget Tests', () {
    testWidgets('Renders Register Match title and form fields', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildTestWidget());
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Register Match'), findsWidgets);
      expect(find.text('Game Name'), findsOneWidget);
      expect(find.text('Duration (minutes)'), findsOneWidget);
      expect(find.text('Match Result'), findsOneWidget);
      expect(find.text('Win'), findsOneWidget);
      expect(find.text('Draw'), findsOneWidget);
      expect(find.text('Loss'), findsOneWidget);
    });

    testWidgets('Allows changing match outcome to Loss or Draw', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildTestWidget());
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      await tester.tap(find.text('Loss'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Draw'));
      await tester.pumpAndSettle();

      expect(find.text('Draw'), findsOneWidget);
    });

    testWidgets('Allows adding a player through player dialog', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildTestWidget());
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      final addPlayerBtn = find.text('Add Player');
      await tester.dragUntilVisible(
        addPlayerBtn,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.tap(addPlayerBtn);
      await tester.pumpAndSettle();

      expect(find.text('Add Player'), findsWidgets);

      final playerNameInput = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      ).first;
      await tester.enterText(playerNameInput, 'Alice');
      await tester.pump();

      final saveDialogBtn = find.widgetWithText(FilledButton, 'Add');
      await tester.tap(saveDialogBtn);
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('Pre-populates fields when in Edit Match mode', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final matchToEdit = GameMatch(
        id: 42,
        gameName: 'Terraforming Mars',
        duration: 90,
        result: MatchResult.won,
        winner: 'Bob',
        players: ['Bob', 'Alice'],
        playedAt: DateTime.now(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(buildTestWidget(matchToEdit: matchToEdit));
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Edit Match'), findsWidgets);
      expect(find.text('Terraforming Mars'), findsWidgets);
      expect(find.text('90'), findsOneWidget);
      expect(find.text('Bob'), findsWidgets);
      expect(find.text('Alice'), findsOneWidget);
    });
  });
}
