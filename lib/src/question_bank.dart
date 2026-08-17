import 'models.dart';

const domains = [
  'Software Engineering',
  'Frontend Development',
  'Backend Development',
  'Full Stack Development',
  'Mobile App Development',
  'DevOps Engineering',
  'Cloud Engineering',
  'Site Reliability Engineering',
  'Quality Assurance & Testing',
  'Game Development',
  'Embedded Systems & IoT',
  'Data Science',
  'Data Analytics',
  'Data Engineering',
  'Business Intelligence',
  'Artificial Intelligence',
  'Machine Learning Engineering',
  'Generative AI Engineering',
  'Natural Language Processing',
  'Computer Vision',
  'Cyber Security',
  'Network Engineering',
  'Database Administration',
  'Blockchain Development',
  'Product Management',
  'Project Management',
  'UI/UX Design',
  'Graphic Design',
  'Digital Marketing',
  'Sales & Business Development',
  'Human Resources',
  'Finance & Accounting',
  'Banking & Investment',
  'Operations & Supply Chain',
  'Customer Support',
  'Healthcare & Nursing',
  'Pharmacy',
  'Civil Engineering',
  'Mechanical Engineering',
  'Electrical Engineering',
  'Electronics Engineering',
  'Automobile Engineering',
  'Architecture',
  'Teaching & Education',
  'Legal & Compliance',
  'Research & Development',
  'Content Writing',
  'Public Relations',
  'Hospitality & Tourism',
  'Government & Public Service',
];

const _curatedQuestions = <InterviewQuestion>[
  InterviewQuestion(
    id: 'hr1',
    text: 'Tell me about yourself and why you are interested in this role.',
    type: InterviewType.hr,
    domains: domains,
    difficulty: Difficulty.beginner,
    keywords: ['experience', 'skills', 'role', 'goal', 'value'],
    idealAnswer:
        'Give a concise present-past-future summary linking your experience and skills to the role.',
  ),
  InterviewQuestion(
    id: 'hr2',
    text: 'Describe a difficult situation at work and how you handled it.',
    type: InterviewType.hr,
    domains: domains,
    difficulty: Difficulty.intermediate,
    keywords: ['situation', 'task', 'action', 'result', 'learned'],
    idealAnswer:
        'Use STAR: explain the situation and task, the action you personally took, and a measurable result.',
    starRecommended: true,
  ),
  InterviewQuestion(
    id: 'hr3',
    text: 'Tell me about a time you disagreed with a teammate.',
    type: InterviewType.hr,
    domains: domains,
    difficulty: Difficulty.advanced,
    keywords: ['listen', 'communicate', 'evidence', 'resolution', 'result'],
    idealAnswer:
        'Show empathy, evidence-based communication, constructive resolution, and what the team achieved.',
    starRecommended: true,
  ),
  InterviewQuestion(
    id: 'se1',
    text:
        'What is object-oriented programming and what are its main principles?',
    type: InterviewType.technical,
    domains: ['Software Engineering'],
    difficulty: Difficulty.beginner,
    keywords: [
      'encapsulation',
      'inheritance',
      'polymorphism',
      'abstraction',
      'objects',
    ],
    idealAnswer:
        'OOP models software as objects. Its core principles are encapsulation, inheritance, polymorphism, and abstraction.',
  ),
  InterviewQuestion(
    id: 'se2',
    text: 'How would you design a scalable URL shortening service?',
    type: InterviewType.technical,
    domains: ['Software Engineering'],
    difficulty: Difficulty.advanced,
    keywords: ['hash', 'database', 'cache', 'collision', 'scaling'],
    idealAnswer:
        'Cover ID generation or hashing, collision handling, persistent storage, caching, redirection, and horizontal scaling.',
  ),
  InterviewQuestion(
    id: 'se3',
    text: 'Explain the difference between a process and a thread.',
    type: InterviewType.technical,
    domains: ['Software Engineering'],
    difficulty: Difficulty.intermediate,
    keywords: ['memory', 'resources', 'execution', 'shared', 'isolation'],
    idealAnswer:
        'A process has isolated memory and resources; threads are execution units that share a process memory space.',
  ),
  InterviewQuestion(
    id: 'ds1',
    text: 'What is overfitting and how can you reduce it?',
    type: InterviewType.technical,
    domains: ['Data Science'],
    difficulty: Difficulty.beginner,
    keywords: [
      'training',
      'validation',
      'regularization',
      'cross-validation',
      'generalization',
    ],
    idealAnswer:
        'Overfitting means learning training noise and generalizing poorly. Use validation, regularization, more data, or simpler models.',
  ),
  InterviewQuestion(
    id: 'ds2',
    text: 'How would you evaluate an imbalanced classification model?',
    type: InterviewType.technical,
    domains: ['Data Science'],
    difficulty: Difficulty.intermediate,
    keywords: ['precision', 'recall', 'f1', 'roc', 'confusion matrix'],
    idealAnswer:
        'Use a confusion matrix plus precision, recall, F1 or PR-AUC according to the cost of false positives and negatives.',
  ),
  InterviewQuestion(
    id: 'ds3',
    text: 'Explain the bias-variance tradeoff.',
    type: InterviewType.technical,
    domains: ['Data Science'],
    difficulty: Difficulty.advanced,
    keywords: [
      'bias',
      'variance',
      'underfitting',
      'overfitting',
      'generalization',
    ],
    idealAnswer:
        'Bias causes underfitting while variance causes sensitivity and overfitting; model complexity balances both for generalization.',
  ),
  InterviewQuestion(
    id: 'cs1',
    text: 'What is the principle of least privilege?',
    type: InterviewType.technical,
    domains: ['Cyber Security'],
    difficulty: Difficulty.beginner,
    keywords: ['access', 'permissions', 'minimum', 'risk', 'role'],
    idealAnswer:
        'Give users and systems only the minimum permissions needed for their role, limiting risk and blast radius.',
  ),
  InterviewQuestion(
    id: 'cs2',
    text: 'How would you respond to a suspected data breach?',
    type: InterviewType.technical,
    domains: ['Cyber Security'],
    difficulty: Difficulty.advanced,
    keywords: ['contain', 'preserve', 'investigate', 'notify', 'recover'],
    idealAnswer:
        'Contain the incident, preserve evidence, investigate scope, notify stakeholders as required, eradicate, recover, and review.',
  ),
  InterviewQuestion(
    id: 'pm1',
    text: 'How do you prioritize product features?',
    type: InterviewType.technical,
    domains: ['Product Management'],
    difficulty: Difficulty.intermediate,
    keywords: ['impact', 'effort', 'users', 'strategy', 'evidence'],
    idealAnswer:
        'Combine user evidence, strategic alignment, expected impact, effort, risk, and a transparent prioritization framework.',
  ),
  InterviewQuestion(
    id: 'pm2',
    text: 'A key product metric dropped suddenly. What would you do?',
    type: InterviewType.technical,
    domains: ['Product Management'],
    difficulty: Difficulty.advanced,
    keywords: ['validate', 'segment', 'funnel', 'hypothesis', 'experiment'],
    idealAnswer:
        'Validate the data, segment the change, inspect the funnel, form hypotheses, and test the highest-probability causes.',
  ),
  InterviewQuestion(
    id: 'res1',
    text: 'Which project on your resume best demonstrates your strengths?',
    type: InterviewType.resume,
    domains: domains,
    difficulty: Difficulty.beginner,
    keywords: ['project', 'responsibility', 'skills', 'impact', 'result'],
    idealAnswer:
        'Choose a relevant project, clarify your responsibility and skills, and quantify its result or impact.',
    starRecommended: true,
  ),
  InterviewQuestion(
    id: 'res2',
    text:
        'What was the most important technical decision you made in a recent project?',
    type: InterviewType.resume,
    domains: domains,
    difficulty: Difficulty.intermediate,
    keywords: ['decision', 'alternatives', 'trade-off', 'reason', 'outcome'],
    idealAnswer:
        'Explain the context, alternatives, trade-offs, your reasoning, and the resulting outcome.',
    starRecommended: true,
  ),
  InterviewQuestion(
    id: 'res3',
    text: 'What would you improve if you rebuilt one of your projects today?',
    type: InterviewType.resume,
    domains: domains,
    difficulty: Difficulty.advanced,
    keywords: ['improve', 'limitation', 'design', 'learning', 'impact'],
    idealAnswer:
        'Identify a real limitation, explain a better design, and demonstrate learning without dismissing the original work.',
  ),
];

final List<InterviewQuestion> questionBank = List.unmodifiable(
  InterviewType.values.expand(_buildSection),
);

List<InterviewQuestion> _buildSection(InterviewType type) {
  final curated = _curatedQuestions
      .where((question) => question.type == type)
      .toList();
  final topics = _topics[type]!;
  final prompts = _prompts[type]!;
  var generatedIndex = 0;
  while (curated.length < 60) {
    final topic = topics[generatedIndex % topics.length];
    final prompt = prompts[(generatedIndex ~/ topics.length) % prompts.length];
    final difficulty =
        Difficulty.values[generatedIndex % Difficulty.values.length];
    curated.add(
      InterviewQuestion(
        id: '${type.name}_generated_${generatedIndex + 1}',
        text: prompt.replaceAll('{topic}', topic),
        type: type,
        domains: domains,
        difficulty: difficulty,
        keywords: _keywordsFor(topic),
        idealAnswer: _idealAnswer(type, topic),
        starRecommended:
            type == InterviewType.hr || type == InterviewType.resume,
      ),
    );
    generatedIndex++;
  }
  return curated.take(60).toList();
}

const _topics = <InterviewType, List<String>>{
  InterviewType.resume: [
    'your strongest project',
    'your most challenging project',
    'team collaboration',
    'a technical decision',
    'a project failure',
    'measurable impact',
    'leadership experience',
    'an internship',
    'a certification',
    'a skill you learned',
    'a tight deadline',
    'customer feedback',
    'a design trade-off',
    'testing and quality',
    'your career growth',
  ],
  InterviewType.technical: [
    'data structures',
    'algorithms',
    'object-oriented design',
    'databases',
    'operating systems',
    'computer networks',
    'REST APIs',
    'system design',
    'software testing',
    'version control',
    'cyber security',
    'cloud computing',
    'performance optimization',
    'debugging',
    'clean code',
  ],
  InterviewType.ai: [
    'machine learning',
    'deep learning',
    'neural networks',
    'natural language processing',
    'computer vision',
    'training data',
    'feature engineering',
    'model evaluation',
    'overfitting',
    'transformers',
    'large language models',
    'responsible AI',
    'model deployment',
    'retrieval augmented generation',
    'AI agents',
  ],
  InterviewType.hr: [
    'teamwork',
    'leadership',
    'conflict resolution',
    'time management',
    'adaptability',
    'communication',
    'handling pressure',
    'giving feedback',
    'receiving feedback',
    'motivation',
    'professional strengths',
    'a weakness',
    'workplace ethics',
    'taking initiative',
    'career goals',
  ],
};

const _prompts = <InterviewType, List<String>>{
  InterviewType.resume: [
    'Walk me through {topic} from your resume.',
    'What did you personally contribute to {topic}?',
    'What challenge did you face regarding {topic}, and what was the result?',
    'What would you do differently today regarding {topic}?',
  ],
  InterviewType.technical: [
    'Explain the core concepts of {topic} with an example.',
    'How would you solve a practical problem involving {topic}?',
    'What common mistakes should engineers avoid when working with {topic}?',
    'Compare two approaches used in {topic} and explain their trade-offs.',
  ],
  InterviewType.ai: [
    'Explain {topic} in simple terms and give a practical example.',
    'How would you design and evaluate a solution using {topic}?',
    'What limitations and risks should be considered with {topic}?',
    'Describe a real-world use case for {topic} and the metrics you would track.',
  ],
  InterviewType.hr: [
    'Tell me about a situation that demonstrates your {topic}.',
    'Describe a challenge involving {topic} and how you handled it.',
    'What have you learned about {topic} from your experience?',
    'How would your teammates describe your approach to {topic}?',
  ],
};

List<String> _keywordsFor(String topic) {
  final words = topic
      .toLowerCase()
      .split(' ')
      .where((word) => word.length > 3)
      .toList();
  return {...words, 'example', 'result', 'approach', 'impact'}.take(5).toList();
}

String _idealAnswer(InterviewType type, String topic) => switch (type) {
  InterviewType.hr || InterviewType.resume =>
    'Use the STAR structure, clarify your personal contribution to $topic, and finish with a measurable result and learning.',
  InterviewType.technical =>
    'Define $topic accurately, explain the important components, compare trade-offs, and support the explanation with a practical example.',
  InterviewType.ai =>
    'Explain $topic clearly, cover data, method, evaluation metrics, limitations, responsible use, and a realistic application.',
};
