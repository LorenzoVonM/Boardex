import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bg_app2/database/database_helper.dart';
import 'package:bg_app2/main.dart';

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

  testWidgets('MyApp loads and renders Library title', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MyApp());
    });
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Library'), findsWidgets);
  });
}
