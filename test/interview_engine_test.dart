import 'package:ai_interview/src/interview_engine.dart';
import 'package:ai_interview/src/models.dart';
import 'package:ai_interview/src/question_bank.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keyword-rich answer scores higher than an empty answer', () {
    final engine = InterviewEngine();
    final question = questionBank.firstWhere((q) => q.id == 'se1');
    final strong = engine.evaluate(
      question,
      'Objects use encapsulation, inheritance, polymorphism and abstraction to organize software responsibilities and improve reusable design.',
    );
    final empty = engine.evaluate(question, '');
    expect(strong.overall, greaterThan(empty.overall));
    expect(strong.matchedKeywords.length, 5);
  });

  test('engine selects requested number of domain questions', () {
    final questions = InterviewEngine().questionsFor(
      const InterviewConfig(
        type: InterviewType.technical,
        domain: 'Data Science',
        difficulty: Difficulty.intermediate,
        questionCount: 5,
      ),
    );
    expect(questions, hasLength(5));
    expect(questions.first.domains, contains('Data Science'));
  });

  test('every interview section contains exactly 60 questions', () {
    for (final type in InterviewType.values) {
      expect(
        questionBank.where((question) => question.type == type),
        hasLength(60),
        reason: '${type.name} should contain 60 questions',
      );
    }
    expect(questionBank, hasLength(240));
  });
}
