// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:truthlens/main.dart';

void main() {
  testWidgets('TruthLens App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: TruthLensApp(),
      ),
    );

    // Wait for the route transition to complete using discrete pumps
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify that the login screen renders and shows the welcome message
    expect(find.text('Welcome to TruthLens'), findsOneWidget);
    expect(find.text('Login to continue'), findsOneWidget);
  });
}
