import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('HerCycle Bloom'),
        ),
      ),
    );

    expect(find.text('HerCycle Bloom'), findsOneWidget);
  });
}
