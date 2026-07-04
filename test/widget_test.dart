import 'package:flutter_test/flutter_test.dart';
import 'package:kawaii_quest/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ScreechApp());
    expect(find.byType(ScreechApp), findsOneWidget);
  });
}
