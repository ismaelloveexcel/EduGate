// lib/features/children/providers/children_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/children_repository.dart';

final childrenStreamProvider = StreamProvider<List<ChildModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(childrenRepositoryProvider).watchChildren(user.uid);
});

final selectedChildProvider = StateProvider<ChildModel?>((ref) => null);
