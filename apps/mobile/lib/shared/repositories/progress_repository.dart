// lib/shared/repositories/progress_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attempt_model.dart';
import '../models/progress_model.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(firestore: FirebaseFirestore.instance);
});

class ProgressRepository {
  final FirebaseFirestore _firestore;

  ProgressRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  DocumentReference<Map<String, dynamic>> _progressDoc(String childId) =>
      _firestore.collection('children').doc(childId).collection('progress').doc('current');

  CollectionReference<Map<String, dynamic>> _attemptsCol(String childId) =>
      _firestore.collection('children').doc(childId).collection('attempts');

  Future<ProgressModel> getProgress(String childId) async {
    final doc = await _progressDoc(childId).get();
    if (!doc.exists) {
      return ProgressModel(childId: childId);
    }
    return ProgressModel.fromMap(doc.data()!, childId);
  }

  Stream<ProgressModel> watchProgress(String childId) {
    return _progressDoc(childId).snapshots().map(
          (snap) => snap.exists
              ? ProgressModel.fromMap(snap.data()!, childId)
              : ProgressModel(childId: childId),
        );
  }

  /// Log an attempt and update progress atomically.
  Future<ProgressModel> recordAttempt({
    required AttemptModel attempt,
    required List<AttemptModel> recentAttempts,
    required List<String> subjectsEnabled,
  }) async {
    final progressRef = _progressDoc(attempt.childId);
    final attemptRef = _attemptsCol(attempt.childId).doc(attempt.id);

    late ProgressModel updatedProgress;

    await _firestore.runTransaction((tx) async {
      final progressSnap = await tx.get(progressRef);
      final current = progressSnap.exists
          ? ProgressModel.fromMap(progressSnap.data()!, attempt.childId)
          : ProgressModel(childId: attempt.childId);

      ProgressModel next = current;
      if (attempt.isCorrect) {
        next = current.applyCorrectAnswer();
      }

      // Update adaptive difficulty
      final updatedDifficulties =
          QuizEngineHelper.computeUpdatedDifficulties(
        recentAttempts: [...recentAttempts, attempt],
        progress: next,
        subjects: subjectsEnabled,
      );
      next = next.copyWith(difficultyBySubject: updatedDifficulties);

      tx.set(progressRef, next.toMap());
      tx.set(attemptRef, attempt.toMap());

      updatedProgress = next;
    });

    return updatedProgress;
  }

  Future<List<AttemptModel>> getRecentAttempts(
    String childId, {
    int limit = 100,
  }) async {
    final snap = await _attemptsCol(childId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => AttemptModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<List<AttemptModel>> getAttemptsForDateRange(
    String childId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final snap = await _attemptsCol(childId)
        .where('createdAt',
            isGreaterThanOrEqualTo: from.millisecondsSinceEpoch)
        .where('createdAt', isLessThanOrEqualTo: to.millisecondsSinceEpoch)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => AttemptModel.fromMap(d.data(), d.id))
        .toList();
  }
}

/// Helper to avoid circular import with quiz_engine.dart
class QuizEngineHelper {
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
