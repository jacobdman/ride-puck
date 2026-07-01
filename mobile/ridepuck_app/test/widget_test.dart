import 'package:flutter_test/flutter_test.dart';

import 'package:ridepuck_app/app.dart';

void main() {
  testWidgets('RidePuck app renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RidePuckApp());
    expect(find.text('RidePuck'), findsWidgets);
  });
}
