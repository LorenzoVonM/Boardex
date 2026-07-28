import 'package:flutter_test/flutter_test.dart';
import 'package:bg_app2/main.dart';

void main() {
  testWidgets('MyApp loads and renders Library title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Library'), findsOneWidget);
  });
}
