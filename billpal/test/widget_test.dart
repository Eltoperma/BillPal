// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:billpal/main.dart';

void main() {
  testWidgets('BillPal app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BillPalApp());

    // Verify that our BillPal dashboard loads
    expect(find.text('BillPal'), findsOneWidget);
    expect(find.text('Geteilte Rechnungen mit Freunden'), findsOneWidget);

    // Verify FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Rechnung teilen'), findsOneWidget);
  });
}
