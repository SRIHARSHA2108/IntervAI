import 'package:ai_interview/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('candidate can create account and open the offline dashboard', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const InterviewCoachApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pump();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Alex');
    await tester.enterText(fields.at(1), 'alex@example.com');
    await tester.enterText(fields.at(2), 'secret');
    final submit = find.widgetWithText(FilledButton, 'Create account');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Ready to practice, Alex?'), findsOneWidget);
    expect(find.text('Start interview'), findsOneWidget);
  });
}
