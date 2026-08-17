import 'package:ai_interview/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('searchable domain picker filters and closes safely', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SetupPage()));

    await tester.tap(find.text('Software Engineering'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('professional fields available'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'nursing');
    await tester.pump();
    expect(find.text('Healthcare & Nursing'), findsOneWidget);

    await tester.tap(find.text('Healthcare & Nursing'));
    await tester.pumpAndSettle();
    expect(find.text('Healthcare & Nursing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
