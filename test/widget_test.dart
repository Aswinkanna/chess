import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import your app root widget:
import 'package:flutter_chess/app.dart';

void main() {
  testWidgets('App loads and shows the main UI', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const ChessApp());

    // Allow async initialization (Firebase etc.)
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Ensure the app loads by checking the AppBar title:
    expect(find.text('Flutter Chess'), findsOneWidget);

    // Test UI interaction: if refresh button exists, tap it
    final refreshButton = find.byIcon(Icons.refresh);
    if (refreshButton.evaluate().isNotEmpty) {
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();
    }

    // App should still be present
    expect(find.text('Flutter Chess'), findsOneWidget);
  });
}
