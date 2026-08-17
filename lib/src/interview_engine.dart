import 'dart:math';
import 'models.dart';
import 'question_bank.dart';

class InterviewEngine {
  List<InterviewQuestion> questionsFor(InterviewConfig config) {
    final exact = questionBank
        .where(
          (q) => q.type == config.type && q.domains.contains(config.domain),
        )
        .toList();
    final fallback = questionBank.where((q) => q.type == config.type).toList();
    final pool = exact.isNotEmpty ? exact : fallback;
    pool.sort(
      (a, b) => (a.difficulty.index - config.difficulty.index).abs().compareTo(
        (b.difficulty.index - config.difficulty.index).abs(),
      ),
    );
    if (pool.isEmpty) return questionBank.take(config.questionCount).toList();
    return List.generate(config.questionCount, (i) => pool[i % pool.length]);
  }

  AnswerScore evaluate(InterviewQuestion question, String rawAnswer) {
    final answer = rawAnswer.trim().toLowerCase();
    final words = RegExp(
      r"[a-z0-9'-]+",
    ).allMatches(answer).map((m) => m.group(0)!).toList();
    final matched = question.keywords
        .where((k) => answer.contains(k.toLowerCase()))
        .toList();
    const fillers = {'um', 'uh', 'like', 'basically', 'actually', 'literally'};
    final fillerCount = words.where(fillers.contains).length;
    final keywordScore = question.keywords.isEmpty
        ? 0.0
        : matched.length / question.keywords.length * 100;
    final lengthScore = (words.length / 70 * 100).clamp(0, 100).toDouble();
    final vocabularyScore = words.isEmpty
        ? 0.0
        : (words.toSet().length / words.length * 130).clamp(0, 100).toDouble();
    final relevance = (keywordScore * .7 + lengthScore * .3)
        .clamp(0, 100)
        .toDouble();
    final clarity = (lengthScore * .55 + vocabularyScore * .45)
        .clamp(0, 100)
        .toDouble();
    final fluency = max(0, 100 - fillerCount * 12).toDouble();
    final starHits = [
      'situation',
      'task',
      'action',
      'result',
    ].where(answer.contains).length;
    final star = question.starRecommended
        ? starHits / 4 * 100
        : min(100, clarity + 10).toDouble();
    final feedback = <String>[];
    if (words.length < 35) {
      feedback.add(
        'Add more detail and support your answer with one concrete example.',
      );
    }
    if (matched.length < max(2, question.keywords.length ~/ 2)) {
      feedback.add(
        'Connect your answer more directly to the key ideas in the question.',
      );
    }
    if (fillerCount > 2) {
      feedback.add('Pause silently instead of using filler words.');
    }
    if (question.starRecommended && starHits < 3) {
      feedback.add(
        'Structure the example using Situation, Task, Action, and Result.',
      );
    }
    if (feedback.isEmpty) {
      feedback.add(
        'Strong answer. Improve it further by quantifying the outcome.',
      );
    }
    return AnswerScore(
      relevance: relevance,
      keywords: keywordScore,
      clarity: clarity,
      fluency: fluency,
      star: star,
      fillerWords: fillerCount,
      wordCount: words.length,
      matchedKeywords: matched,
      feedback: feedback,
    );
  }
}
