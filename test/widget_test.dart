// Basic smoke test for the News App.
//
// The default counter test that ships with a new Flutter project referenced
// a `MyApp` widget that doesn't exist in this project (the app's root widget
// is `NewsApp`), so it failed to compile. This test builds the real theme
// used by the app instead, without touching the network layer.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app/core/app_theme.dart';

void main() {
  testWidgets('App theme builds a valid MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(body: Center(child: Text('News App'))),
      ),
    );

    expect(find.text('News App'), findsOneWidget);
  });
}
