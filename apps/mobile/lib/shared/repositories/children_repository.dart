// lib/shared/repositories/children_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/child_model.dart';

final childrenRepositoryProvider = Provider<ChildrenRepository>((ref) {
  return ChildrenRepository(firestore: FirebaseFirestore.instance);
});

class ChildrenRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  ChildrenRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _childrenCol(String parentId) =>
      _firestore.collection('parents').doc(parentId).collection('children');

  Future<List<ChildModel>> getChildren(String parentId) async {
    final snap = await _childrenCol(parentId).get();
    return snap.docs
        .map((d) => ChildModel.fromMap(d.data(), d.id))
        .toList();
  }

  Stream<List<ChildModel>> watchChildren(String parentId) {
    return _childrenCol(parentId).snapshots().map(
          (snap) => snap.docs
              .map((d) => ChildModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Future<ChildModel> addChild({
    required String parentId,
    required String name,
    required int age,
    required String grade,
    required String pinHash,
    required String avatarId,
    List<String> subjectsEnabled = const ['math', 'science', 'english'],
    int quizIntervalMinutes = 30,
  }) async {
    final id = _uuid.v4();
    final child = ChildModel(
      id: id,
      parentId: parentId,
      name: name,
      age: age,
      grade: grade,
      pinHash: pinHash,
      avatarId: avatarId,
      createdAt: DateTime.now(),
      subjectsEnabled: subjectsEnabled,
      quizIntervalMinutes: quizIntervalMinutes,
    );

    final batch = _firestore.batch();
    batch.set(_childrenCol(parentId).doc(id), child.toMap());
    // Also store a top-level mapping for security rule lookups
    batch.set(
      _firestore.collection('childParentMap').doc(id),
      {'parentId': parentId},
    );
    await batch.commit();

    return child;
  }

  Future<void> updateChild(String parentId, ChildModel child) async {
    await _childrenCol(parentId).doc(child.id).update(child.toMap());
  }

  Future<void> deleteChild(String parentId, String childId) async {
    final batch = _firestore.batch();
    batch.delete(_childrenCol(parentId).doc(childId));
    batch.delete(_firestore.collection('childParentMap').doc(childId));
    await batch.commit();
  }
}
