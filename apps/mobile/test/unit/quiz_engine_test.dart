// test/unit/quiz_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:edugate/shared/models/attempt_model.dart';
import 'package:edugate/shared/models/progress_model.dart';
import 'package:edugate/shared/models/question_model.dart';
import 'package:edugate/shared/services/quiz_engine.dart';

List<QuestionModel> _makeQuestions({
  int count = 10,
  String subject = 'math',
  Difficulty difficulty = Difficulty.easy,
}) {
  return List.generate(
    count,
    (i) => QuestionModel(
      id: 'q$i',
      subject: subject,
      difficulty: difficulty,
      type: QuestionType.mcq,
      prompt: 'Question $i?',
      options: ['A', 'B', 'C', 'D'],
      correctAnswer: 'A',
    ),
  );
}

List<AttemptModel> _makeAttempts({
  required String subject,
  required int correct,
  required int total,
  Difficulty difficulty = Difficulty.easy,
}) {
  return List.generate(
    total,
    (i) => AttemptModel(
      id: 'a$i',
      childId: 'c1',
      questionId: 'q$i',
      subject: subject,
      difficulty: difficulty,
      type: QuestionType.mcq,
      isCorrect: i < correct,
      timeTakenMs: 1000,
      createdAt: DateTime(2024, 1, 15),
    ),
  );
}

void main() {
  group('QuizEngine.selectQuestions', () {
    final progress = ProgressModel(childId: 'c1');

    test('returns empty list when no questions available', () {
      final result = QuizEngine.selectQuestions(
        allQuestions: [],
        recentAttempts: [],
        progress: progress,
        subjectsEnabled: ['math'],
      );
      expect(result, isEmpty);
    });

    test('returns empty list when subjects list is empty', () {
      final questions = _makeQuestions();
      final result = QuizEngine.selectQuestions(
        allQuestions: questions,
        recentAttempts: [],
        progress: progress,
        subjectsEnabled: [],
      );
      expect(result, isEmpty);
    });

    test('filters questions by enabled subjects', () {
      final mathQuestions = _makeQuestions(count: 5, subject: 'math');
      final scienceQuestions = _makeQuestions(count: 5, subject: 'science');
      final all = [...mathQuestions, ...scienceQuestions];

      final result = QuizEngine.selectQuestions(
        allQuestions: all,
        recentAttempts: [],
        progress: progress,
        subjectsEnabled: ['math'],
        count: 10,
      );

      expect(result.every((q) => q.subject == 'math'), isTrue);
    });

    test('returns at most count questions', () {
      final questions = _makeQuestions(count: 20, subject: 'math');
      final result = QuizEngine.selectQuestions(
        allQuestions: questions,
        recentAttempts: [],
        progress: progress,
        subjectsEnabled: ['math'],
        count: 5,
      );
      expect(result.length, 5);
    });

    test('returns all available if pool smaller than count', () {
      final questions = _makeQuestions(count: 3, subject: 'math');
      final result = QuizEngine.selectQuestions(
        allQuestions: questions,
        recentAttempts: [],
        progress: progress,
        subjectsEnabled: ['math'],
        count: 10,
      );
      expect(result.length, 3);
    });

    test('prefers target difficulty questions when available', () {
      // Progress says math is medium difficulty
      final progressMedium = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'medium'},
      );

      final easyQs = _makeQuestions(count: 5, subject: 'math', difficulty: Difficulty.easy);
      final mediumQs = _makeQuestions(count: 5, subject: 'math', difficulty: Difficulty.medium);
      // Rename IDs to avoid duplicates
      final mediumRenamedQs = mediumQs.map((q) => QuestionModel(
        id: 'm_${q.id}',
        subject: q.subject,
        difficulty: q.difficulty,
        type: q.type,
        prompt: q.prompt,
        options: q.options,
        correctAnswer: q.correctAnswer,
      )).toList();

      final result = QuizEngine.selectQuestions(
        allQuestions: [...easyQs, ...mediumRenamedQs],
        recentAttempts: [],
        progress: progressMedium,
        subjectsEnabled: ['math'],
        count: 5,
      );

      // All results should be medium difficulty since they score higher
      expect(result.every((q) => q.difficulty == Difficulty.medium), isTrue);
    });

    test('adaptive difficulty raises difficulty after high accuracy', () {
      // 18 correct out of 20 attempts = 90% accuracy → should raise from easy to medium
      final attempts = _makeAttempts(
        subject: 'math',
        correct: 18,
        total: 20,
        difficulty: Difficulty.easy,
      );
      final progressEasy = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'easy'},
      );

      final targetDiffs = QuizEngine.selectQuestions(
        allQuestions: [
          ..._makeQuestions(count: 5, subject: 'math', difficulty: Difficulty.easy),
          ..._makeQuestions(count: 5, subject: 'math', difficulty: Difficulty.medium)
              .map((q) => QuestionModel(
                    id: 'm_${q.id}',
                    subject: q.subject,
                    difficulty: Difficulty.medium,
                    type: q.type,
                    prompt: q.prompt,
                    options: q.options,
                    correctAnswer: q.correctAnswer,
                  ))
              .toList(),
        ],
        recentAttempts: attempts,
        progress: progressEasy,
        subjectsEnabled: ['math'],
        count: 5,
      );

      // Medium questions should be prioritized due to high accuracy raising difficulty
      expect(
        targetDiffs.every((q) => q.difficulty == Difficulty.medium),
        isTrue,
      );
    });

    test('adaptive difficulty lowers difficulty after low accuracy', () {
      // 5 correct out of 20 = 25% accuracy → lower from hard to medium
      final attempts = _makeAttempts(
        subject: 'math',
        correct: 5,
        total: 20,
        difficulty: Difficulty.hard,
      );
      final progressHard = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'hard'},
      );

      final easyQs = _makeQuestions(count: 5, subject: 'math', difficulty: Difficulty.easy);
      final mediumQs = _makeQuestions(count: 5, subject: 'math', difficulty: Difficulty.medium)
          .map((q) => QuestionModel(
                id: 'm_${q.id}',
                subject: q.subject,
                difficulty: Difficulty.medium,
                type: q.type,
                prompt: q.prompt,
                options: q.options,
                correctAnswer: q.correctAnswer,
              ))
          .toList();

      final result = QuizEngine.selectQuestions(
        allQuestions: [...easyQs, ...mediumQs],
        recentAttempts: attempts,
        progress: progressHard,
        subjectsEnabled: ['math'],
        count: 5,
      );

      expect(
        result.every((q) => q.difficulty == Difficulty.medium),
        isTrue,
      );
    });
  });

  group('QuizEngine.computeUpdatedDifficulties', () {
    test('raises difficulty for subject with >80% accuracy', () {
      final attempts = _makeAttempts(subject: 'math', correct: 17, total: 20);
      final progress = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'easy'},
      );

      final updated = QuizEngine.computeUpdatedDifficulties(
        recentAttempts: attempts,
        progress: progress,
        subjects: ['math'],
      );

      expect(updated['math'], 'medium');
    });

    test('lowers difficulty for subject with <50% accuracy', () {
      final attempts = _makeAttempts(subject: 'math', correct: 5, total: 20, difficulty: Difficulty.hard);
      final progress = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'hard'},
      );

      final updated = QuizEngine.computeUpdatedDifficulties(
        recentAttempts: attempts,
        progress: progress,
        subjects: ['math'],
      );

      expect(updated['math'], 'medium');
    });

    test('keeps difficulty unchanged when no attempts for subject', () {
      final progress = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'medium'},
      );

      final updated = QuizEngine.computeUpdatedDifficulties(
        recentAttempts: [],
        progress: progress,
        subjects: ['math'],
      );

      expect(updated['math'], 'medium');
    });
  });
}
