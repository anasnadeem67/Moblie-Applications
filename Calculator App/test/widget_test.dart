import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  testWidgets('Calculator performs basic arithmetic correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CalculatorApp());

    // Verify that the initial display text is '0'.
    expect(find.text('0'), findsOneWidget);

    // Tap on the '2' button.
    await tester.tap(find.text('2'));
    await tester.pump();

    // Verify that the display shows '2'.
    expect(find.text('2'), findsOneWidget);

    // Tap on the '+' button.
    await tester.tap(find.text('+'));
    await tester.pump();

    // Tap on the '2' button again.
    await tester.tap(find.text('2'));
    await tester.pump();

    // Verify the display now shows '2+2'.
    expect(find.text('2+2'), findsOneWidget);

    // Tap on the '=' button.
    await tester.tap(find.text('='));
    await tester.pump();

    // Verify the result is '4'.
    expect(find.text('4'), findsOneWidget);
  });
}
