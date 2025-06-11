// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keeper/main.dart';
import 'package:keeper/providers/settings_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize settings provider
    final settingsProvider = SettingsProvider();
    await settingsProvider.init();

    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(settingsProvider: settingsProvider));

    // Verify basic app structure
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
