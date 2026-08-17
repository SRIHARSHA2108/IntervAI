enum InterviewType { resume, technical, ai, hr }

enum Difficulty { beginner, intermediate, advanced }

extension InterviewTypeLabel on InterviewType {
  String get label => switch (this) {
    InterviewType.hr => 'HR interview',
    InterviewType.technical => 'Technical interview',
    InterviewType.resume => 'Resume-based',
    InterviewType.ai => 'AI interview',
  };
}

extension DifficultyLabel on Difficulty {
  String get label => switch (this) {
    Difficulty.beginner => 'Beginner',
    Difficulty.intermediate => 'Intermediate',
    Difficulty.advanced => 'Advanced',
  };
}

class InterviewConfig {
  const InterviewConfig({
    required this.type,
    required this.domain,
    required this.difficulty,
    this.questionCount = 5,
  });
  final InterviewType type;
  final String domain;
  final Difficulty difficulty;
  final int questionCount;
}

class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.domains,
    required this.difficulty,
    required this.keywords,
    required this.idealAnswer,
    this.starRecommended = false,
  });
  final String id;
  final String text;
  final InterviewType type;
  final List<String> domains;
  final Difficulty difficulty;
  final List<String> keywords;
  final String idealAnswer;
  final bool starRecommended;
}

class AnswerScore {
  const AnswerScore({
    required this.relevance,
    required this.keywords,
    required this.clarity,
    required this.fluency,
    required this.star,
    required this.fillerWords,
    required this.wordCount,
    required this.matchedKeywords,
    required this.feedback,
  });
  final double relevance, keywords, clarity, fluency, star;
  final int fillerWords, wordCount;
  final List<String> matchedKeywords, feedback;
  double get overall =>
      (relevance * .35 +
              keywords * .25 +
              clarity * .15 +
              fluency * .15 +
              star * .10)
          .clamp(0, 100);
}

class AnswerResult {
  const AnswerResult({
    required this.question,
    required this.answer,
    required this.score,
  });
  final InterviewQuestion question;
  final String answer;
  final AnswerScore score;
}

class InterviewSession {
  const InterviewSession({
    required this.id,
    required this.date,
    required this.config,
    required this.results,
  });
  final String id;
  final DateTime date;
  final InterviewConfig config;
  final List<AnswerResult> results;
  double get score => results.isEmpty
      ? 0
      : results.map((e) => e.score.overall).reduce((a, b) => a + b) /
            results.length;
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'type': config.type.name,
    'domain': config.domain,
    'difficulty': config.difficulty.name,
    'score': score,
    'questions': results.length,
  };
}
