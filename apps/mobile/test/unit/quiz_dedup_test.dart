import 'package:flutter_test/flutter_test.dart';
import 'package:edugate/shared/models/attempt_model.dart';
import 'package:edugate/shared/models/progress_model.dart';
import 'package:edugate/shared/models/question_model.dart';
import 'package:edugate/shared/services/quiz_engine.dart';

void main() {
  group('QuizEngine question deduplication', () {
    final progress = ProgressModel(childId: 'c1');

    List<QuestionModel> makeQuestions(int count) {
      return List.generate(
        count,
        (i) => QuestionModel(
          id: 'q$i',
          subject: 'math',
          difficulty: Difficulty.easy,
          type: QuestionType.mcq,
          prompt: 'Q$i?',
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: 'A',
        ),
      );
    }

    List<AttemptModel> makeAttempts(List<String> questionIds) {
      return questionIds.map((qid) => AttemptModel(
        id: 'a_$qid',
        childId: 'c1',
        questionId: qid,
        subject: 'math',
        difficulty: Difficulty.easy,
        type: QuestionType.mcq,
        isCorrect: true,
        timeTakenMs: 1000,
        createdAt: DateTime(2024, 1, 15),
      )).toList();
    }

    test('excludes recently attempted questions', () {
      final questions = makeQuestions(20);
      final recentAttempts = makeAttempts(['q0', 'q1', 'q2', 'q3', 'q4']);

      final result = QuizEngine.selectQuestions(
        allQuestions: questions,
        recentAttempts: recentAttempts,
        progress: progress,
        subjectsEnabled: ['math'],
        count: 5,
      );

      final selectedIds = result.map((q) => q.id).toSet();
      expect(selectedIds.contains('q0'), isFalse);
      expect(selectedIds.contains('q1'), isFalse);
      expect(selectedIds.contains('q2'), isFalse);
      expect(selectedIds.contains('q3'), isFalse);
      expect(selectedIds.contains('q4'), isFalse);
    });

    test('falls back to full pool when dedup leaves too few questions', () {
      final questions = makeQuestions(5);
      // All 5 questions were recently attempted
      final recentAttempts = makeAttempts(['q0', 'q1', 'q2', 'q3', 'q4']);

      final result = QuizEngine.selectQuestions(
        allQuestions: questions,
        recentAttempts: recentAttempts,
        progress: progress,
        subjectsEnabled: ['math'],
        count: 5,
      );

      expect(result.length, 5);
    });

    test('only excludes up to kAvoidLastN recent attempts', () {
      final questions = makeQuestions(20);
      // 15 recent attempts, but only last 10 should be excluded
      final recentAttempts = makeAttempts(
        List.generate(15, (i) => 'q$i'),
      );

      final result = QuizEngine.selectQuestions(
        allQuestions: questions,
        recentAttempts: recentAttempts,
        progress: progress,
        subjectsEnabled: ['math'],
        count: 5,
      );

      // Questions q10-q14 should be in the eligible pool (beyond kAvoidLastN)
      final selectedIds = result.map((q) => q.id).toSet();
      // The first 10 (q0-q9) should be excluded if enough alternatives exist
      for (final id in selectedIds) {
        final idx = int.parse(id.substring(1));
        expect(idx, greaterThanOrEqualTo(10));
      }
    });
  });
}
