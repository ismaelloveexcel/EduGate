// lib/shared/repositories/auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parent_model.dart';
import '../services/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: AuthService(),
    firestore: FirebaseFirestore.instance,
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthRepository {
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required AuthService authService,
    required FirebaseFirestore firestore,
  })  : _authService = authService,
        _firestore = firestore;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  Future<ParentModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _authService.signUp(email: email, password: password);
    final uid = cred.user!.uid;

    final parent = ParentModel(
      id: uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('parents').doc(uid).set(parent.toMap());
    return parent;
  }

  Future<ParentModel?> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _authService.signIn(email: email, password: password);
    final uid = cred.user!.uid;
    return getParent(uid);
  }

  Future<ParentModel?> getParent(String parentId) async {
    final doc =
        await _firestore.collection('parents').doc(parentId).get();
    if (!doc.exists) return null;
    return ParentModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> signOut() => _authService.signOut();

  Future<void> sendPasswordReset(String email) =>
      _authService.sendPasswordResetEmail(email);
}
