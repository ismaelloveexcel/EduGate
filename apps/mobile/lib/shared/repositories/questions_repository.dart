// lib/shared/repositories/questions_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_model.dart';

final questionsRepositoryProvider = Provider<QuestionsRepository>((ref) {
  return QuestionsRepository(firestore: FirebaseFirestore.instance);
});

class QuestionsRepository {
  final FirebaseFirestore _firestore;

  QuestionsRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<QuestionModel>> fetchQuestions({
    required List<String> subjects,
    Difficulty? difficulty,
    int limit = 50,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('questions');

    if (subjects.isNotEmpty) {
      query = query.where('subject', whereIn: subjects.take(10).toList());
    }
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty.name);
    }
    query = query.limit(limit);

    final snap = await query.get();
    return snap.docs
        .map((d) => QuestionModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<QuestionModel?> getQuestion(String questionId) async {
    final doc =
        await _firestore.collection('questions').doc(questionId).get();
    if (!doc.exists) return null;
    return QuestionModel.fromMap(doc.data()!, doc.id);
  }

  /// Seed questions (admin/dev use only — call from scripts/seed_questions.dart)
  Future<void> seedQuestions(List<QuestionModel> questions) async {
    final batch = _firestore.batch();
    for (final q in questions) {
      batch.set(_firestore.collection('questions').doc(q.id), q.toMap());
    }
    await batch.commit();
  }
}
