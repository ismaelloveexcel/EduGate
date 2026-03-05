// lib/features/auth/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/notification_service.dart';
import '../../../shared/models/parent_model.dart';
import '../../../shared/repositories/auth_repository.dart';

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, ParentModel?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<ParentModel?> {
  @override
  Future<ParentModel?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final user = repo.currentUser;
    if (user == null) return null;
    // Register / refresh FCM token whenever auth state is restored.
    await ref
        .read(notificationServiceProvider)
        .registerToken(parentId: user.uid);
    return repo.getParent(user.uid);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final parent = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      if (parent != null) {
        await ref
            .read(notificationServiceProvider)
            .registerToken(parentId: parent.id);
      }
      return parent;
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final parent = await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            displayName: displayName,
          );
      if (parent != null) {
        await ref
            .read(notificationServiceProvider)
            .registerToken(parentId: parent.id);
      }
      return parent;
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
