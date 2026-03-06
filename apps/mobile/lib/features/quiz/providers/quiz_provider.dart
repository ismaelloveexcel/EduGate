// lib/features/quiz/providers/quiz_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/attempt_model.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/question_model.dart';
import '../../../shared/models/progress_model.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/children_repository.dart';
import '../../../shared/repositories/progress_repository.dart';
import '../../../shared/repositories/questions_repository.dart';
import '../../../shared/services/quiz_engine.dart';

final _uuid = const Uuid();

class QuizState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final Map<String, bool> answers; // questionId -> isCorrect
  final bool isComplete;
  final ProgressModel? updatedProgress;
  final bool loading;
  final String? error;

  // Cached data from initialize — reused across all submitAnswer calls.
  final ChildModel? child;
  final String? parentId;
  final List<AttemptModel> recentAttempts;

  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.isComplete = false,
    this.updatedProgress,
    this.loading = false,
    this.error,
    this.child,
    this.parentId,
    this.recentAttempts = const [],
  });

  QuizState copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    Map<String, bool>? answers,
    bool? isComplete,
    ProgressModel? updatedProgress,
    bool? loading,
    String? error,
    ChildModel? child,
    String? parentId,
    List<AttemptModel>? recentAttempts,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isComplete: isComplete ?? this.isComplete,
      updatedProgress: updatedProgress ?? this.updatedProgress,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      child: child ?? this.child,
      parentId: parentId ?? this.parentId,
      recentAttempts: recentAttempts ?? this.recentAttempts,
    );
  }

  int get correctCount => answers.values.where((v) => v).length;
  int get totalCount => answers.length;
  int get xpEarned => correctCount * kXpPerCorrect;
  int get coinsEarned => correctCount * kCoinsPerCorrect;
}

class QuizNotifier extends AsyncNotifier<QuizState> {
  late final String _childId;

  @override
  Future<QuizState> build() async => const QuizState();

  Future<void> initialize(String childId) async {
    _childId = childId;
    state = const AsyncLoading();

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('Not authenticated');

      // Get child settings
      final children =
          await ref.read(childrenRepositoryProvider).getChildren(user.uid);
      final child = children.firstWhere((c) => c.id == childId);

      // Get progress
      final progress =
          await ref.read(progressRepositoryProvider).getProgress(user.uid, childId);

      // Get recent attempts for adaptive difficulty (cached for the session)
      final recentAttempts = await ref
          .read(progressRepositoryProvider)
          .getRecentAttempts(user.uid, childId, limit: 60);

      // Fetch questions
      final allQuestions = await ref
          .read(questionsRepositoryProvider)
          .fetchQuestions(subjects: child.subjectsEnabled);

      // Select questions using quiz engine
      final selected = QuizEngine.selectQuestions(
        allQuestions: allQuestions,
        recentAttempts: recentAttempts,
        progress: progress,
        subjectsEnabled: child.subjectsEnabled,
        count: 5,
      );

      if (selected.isEmpty) {
        state = AsyncData(const QuizState(
          error: 'No questions available for your subjects.',
        ));
        return;
      }

      state = AsyncData(QuizState(
        questions: selected,
        child: child,
        parentId: user.uid,
        recentAttempts: recentAttempts,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> submitAnswer({
    required QuestionModel question,
    required String userAnswer,
    required int timeTakenMs,
  }) async {
    final current = state.value;
    if (current == null) return;

    // Use cached child and parentId — no extra Firestore reads per answer.
    final child = current.child;
    final parentId = current.parentId;
    if (child == null || parentId == null) return;

    final isCorrect =
        userAnswer.trim().toLowerCase() ==
            question.correctAnswer.trim().toLowerCase();

    final attempt = AttemptModel(
      id: _uuid.v4(),
      childId: _childId,
      questionId: question.id,
      subject: question.subject,
      difficulty: question.difficulty,
      type: question.type,
      isCorrect: isCorrect,
      timeTakenMs: timeTakenMs,
      createdAt: DateTime.now(),
    );

    // Prepend the new attempt to the cached list so difficulty logic stays
    // current without any additional Firestore reads.
    final updatedRecentAttempts = [attempt, ...current.recentAttempts];

    final updatedProgress =
        await ref.read(progressRepositoryProvider).recordAttempt(
              parentId: parentId,
              attempt: attempt,
              recentAttempts: updatedRecentAttempts,
              subjectsEnabled: child.subjectsEnabled,
            );

    final newAnswers = Map<String, bool>.from(current.answers)
      ..[question.id] = isCorrect;

    final nextIndex = current.currentIndex + 1;
    final isComplete = nextIndex >= current.questions.length;

    state = AsyncData(current.copyWith(
      currentIndex: nextIndex,
      answers: newAnswers,
      isComplete: isComplete,
      updatedProgress: updatedProgress,
      recentAttempts: updatedRecentAttempts,
    ));
  }
}

final quizNotifierProvider =
    AsyncNotifierProvider<QuizNotifier, QuizState>(
  QuizNotifier.new,
);
