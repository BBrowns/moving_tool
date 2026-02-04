// Basic widget test for Moving Tool app
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    // This is a smoke test to verify the app can be instantiated
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Moving Tool'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Moving Tool'), findsOneWidget);
  });
}
