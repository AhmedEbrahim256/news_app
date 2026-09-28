import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/app_theme.dart';

void main() {
  testWidgets('renders the app title', (tester) async {
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
