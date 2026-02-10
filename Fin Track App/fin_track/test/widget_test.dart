// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importing FinTrackApp from the main entry point to initiate testing
import 'package:fin_track/main.dart'; 

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // UPDATED: Replaced 'MyApp' with 'FinTrackApp' to align with the actual class name in main.dart
    await tester.pumpWidget(const FinTrackApp());

    // Verifying that the core MaterialApp widget is successfully loaded into the widget tree
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Note: Since Firebase is not initialized in the local test environment, 
    // this test serves as a basic smoke test to ensure the initial widget pump executes without errors.
  });
}