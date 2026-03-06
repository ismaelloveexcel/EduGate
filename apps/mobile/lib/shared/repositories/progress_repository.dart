// lib/shared/repositories/progress_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attempt_model.dart';
import '../models/progress_model.dart';
import '../services/quiz_engine.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(firestore: FirebaseFirestore.instance);
});

class ProgressRepository {
  final FirebaseFirestore _firestore;

  ProgressRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // All child data lives under the parent subtree:
  // parents/{parentId}/children/{childId}/progress/main
  // parents/{parentId}/children/{childId}/attempts/{attemptId}
  DocumentReference<Map<String, dynamic>> _progressDoc(
          String parentId, String childId) =>
      _firestore
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('progress')
          .doc('main');

  CollectionReference<Map<String, dynamic>> _attemptsCol(
          String parentId, String childId) =>
      _firestore
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('attempts');

  Future<ProgressModel> getProgress(String parentId, String childId) async {
    final doc = await _progressDoc(parentId, childId).get();
    if (!doc.exists) {
      return ProgressModel(childId: childId);
    }
    return ProgressModel.fromMap(doc.data()!, childId);
  }

  Stream<ProgressModel> watchProgress(String parentId, String childId) {
    return _progressDoc(parentId, childId).snapshots().map(
          (snap) => snap.exists
              ? ProgressModel.fromMap(snap.data()!, childId)
              : ProgressModel(childId: childId),
        );
  }

  /// Log an attempt and update progress atomically.
  Future<ProgressModel> recordAttempt({
    required String parentId,
    required AttemptModel attempt,
    required List<AttemptModel> recentAttempts,
    required List<String> subjectsEnabled,
  }) async {
    final progressRef = _progressDoc(parentId, attempt.childId);
    final attemptRef = _attemptsCol(parentId, attempt.childId).doc(attempt.id);

    late ProgressModel updatedProgress;

    await _firestore.runTransaction((tx) async {
      final progressSnap = await tx.get(progressRef);
      final current = progressSnap.exists
          ? ProgressModel.fromMap(progressSnap.data()!, attempt.childId)
          : ProgressModel(childId: attempt.childId);

      // applyAttempt always increments daily count and manages streaks;
      // XP/coins are only awarded when isCorrect is true.
      ProgressModel next = current.applyAttempt(
        isCorrect: attempt.isCorrect,
        now: attempt.createdAt,
      );

      // Update adaptive difficulty
      final updatedDifficulties = QuizEngine.computeUpdatedDifficulties(
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
    String parentId,
    String childId, {
    int limit = 100,
  }) async {
    final snap = await _attemptsCol(parentId, childId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => AttemptModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<List<AttemptModel>> getAttemptsForDateRange(
    String parentId,
    String childId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final snap = await _attemptsCol(parentId, childId)
        .where('createdAt',
            isGreaterThanOrEqualTo: from.millisecondsSinceEpoch)
        .where('createdAt', isLessThanOrEqualTo: to.millisecondsSinceEpoch)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => AttemptModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<void> purchaseCosmetic({
    required String parentId,
    required String childId,
    required String itemId,
    required int coinCost,
  }) async {
    final progressRef = _progressDoc(parentId, childId);
    final ownedRef = _firestore
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .doc(childId)
        .collection('ownedCosmetics')
        .doc(itemId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(progressRef);
      final coins = snap.data()?['coins'] as int? ?? 0;
      if (coins < coinCost) throw Exception('Not enough coins');
      tx.update(progressRef, {'coins': coins - coinCost});
      tx.set(ownedRef, {
        'purchasedAt': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  Stream<Set<String>> watchOwnedCosmetics(String parentId, String childId) {
    return _firestore
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .doc(childId)
        .collection('ownedCosmetics')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }
}

