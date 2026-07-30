import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bg_app2/database/database_helper.dart';
import 'package:bg_app2/screens/main_navigation_shell.dart';

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

  Widget buildTestWidget() {
    return const MaterialApp(
      home: MainNavigationShell(),
    );
  }

  group('MainNavigationShell Floating Bottom Navigation Tests', () {
    testWidgets('Initial tab displays Library and floating nav icons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildTestWidget());
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Library'), findsWidgets);
      expect(find.text('Matches'), findsWidgets);
      expect(find.text('Summary'), findsWidgets);
      expect(find.text('Tools'), findsWidgets);
    });

    testWidgets('Tapping Matches tab switches to MatchesScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildTestWidget());
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 300));

      await tester.runAsync(() async {
        await tester.tap(find.text('Matches').last);
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No matches recorded'), findsOneWidget);
    });

    testWidgets('Tapping Summary tab switches to SummarySearchScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildTestWidget());
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 300));

      await tester.runAsync(() async {
        await tester.tap(find.text('Summary').last);
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Find Matches'), findsOneWidget);
    });

    testWidgets('Tapping Tools tab switches to PlayerToolScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildTestWidget());
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 300));

      await tester.runAsync(() async {
        await tester.tap(find.text('Tools').last);
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Competitive'), findsOneWidget);
    });
  });
}
