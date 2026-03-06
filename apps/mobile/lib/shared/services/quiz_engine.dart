// lib/shared/services/quiz_engine.dart
import '../models/question_model.dart';
import '../models/attempt_model.dart';
import '../models/progress_model.dart';

/// Selects the next batch of questions for a quiz session.
///
/// - Respects [subjectsEnabled] filter.
/// - Uses adaptive difficulty based on recent 20 attempts per subject.
/// - Returns up to [count] questions.
class QuizEngine {
  /// Select questions for a quiz session.
  ///
  /// [allQuestions] – full question pool (or pre-filtered by caller).
  /// [recentAttempts] – last N attempts for this child (used for adaptive difficulty).
  /// [progress] – child's current progress (contains difficultyBySubject).
  /// [subjectsEnabled] – which subjects to include.
  /// [count] – number of questions to return.
  static List<QuestionModel> selectQuestions({
    required List<QuestionModel> allQuestions,
    required List<AttemptModel> recentAttempts,
    required ProgressModel progress,
    required List<String> subjectsEnabled,
    int count = 5,
  }) {
    if (allQuestions.isEmpty || subjectsEnabled.isEmpty) return [];

    // Filter by enabled subjects
    final eligible = allQuestions
        .where((q) => subjectsEnabled.contains(q.subject))
        .toList();

    if (eligible.isEmpty) return [];

    // Compute target difficulty per subject using adaptive logic
    final targetDifficulty = _computeTargetDifficulties(
      recentAttempts: recentAttempts,
      progress: progress,
      subjects: subjectsEnabled,
    );

    // Score and sort questions
    final scored = eligible.map((q) {
      final target = targetDifficulty[q.subject] ?? Difficulty.easy;
      final diffMatch = q.difficulty == target ? 2 : 1;
      return _ScoredQuestion(q, diffMatch);
    }).toList();

    // Shuffle within equal scores for variety
    scored.shuffle();
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.take(count).map((s) => s.question).toList();
  }

  /// Compute adaptive target difficulty per subject from recent attempts.
  static Map<String, Difficulty> _computeTargetDifficulties({
    required List<AttemptModel> recentAttempts,
    required ProgressModel progress,
    required List<String> subjects,
  }) {
    final result = <String, Difficulty>{};

    for (final subject in subjects) {
      final subjectAttempts =
          recentAttempts.where((a) => a.subject == subject).take(20).toList();

      final current = Difficulty.values.firstWhere(
        (d) => d.name == (progress.difficultyBySubject[subject] ?? 'easy'),
        orElse: () => Difficulty.easy,
      );

      if (subjectAttempts.isEmpty) {
        result[subject] = current;
        continue;
      }

      final accuracy =
          subjectAttempts.where((a) => a.isCorrect).length /
              subjectAttempts.length;

      result[subject] = progress.adaptiveDifficulty(subject, accuracy);
    }

    return result;
  }

  /// Update the difficultyBySubject map in progress based on recent attempts.
  static Map<String, String> computeUpdatedDifficulties({
    required List<AttemptModel> recentAttempts,
    required ProgressModel progress,
    required List<String> subjects,
  }) {
    final updated = Map<String, String>.from(progress.difficultyBySubject);

    for (final subject in subjects) {
      final subjectAttempts =
          recentAttempts.where((a) => a.subject == subject).take(20).toList();

      if (subjectAttempts.isEmpty) continue;

      final accuracy =
          subjectAttempts.where((a) => a.isCorrect).length /
              subjectAttempts.length;

      final newDiff = progress.adaptiveDifficulty(subject, accuracy);
      updated[subject] = newDiff.name;
    }

    return updated;
  }
}

class _ScoredQuestion {
  final QuestionModel question;
  final int score;
  _ScoredQuestion(this.question, this.score);
}
