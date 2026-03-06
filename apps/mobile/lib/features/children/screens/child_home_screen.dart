// lib/features/children/screens/child_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/children_repository.dart';
import '../../../shared/repositories/progress_repository.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/progress_model.dart';

final _childProvider =
    FutureProvider.family<ChildModel?, String>((ref, childId) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  final children =
      await ref.read(childrenRepositoryProvider).getChildren(user.uid);
  return children.firstWhere((c) => c.id == childId,
      orElse: () => throw Exception('Child not found'));
});

/// Top-level provider so Riverpod can cache and share the stream subscription.
typedef _ProgressKey = ({String parentId, String childId});

final _progressStreamProvider =
    StreamProvider.family<ProgressModel, _ProgressKey>((ref, key) {
  return ref
      .read(progressRepositoryProvider)
      .watchProgress(key.parentId, key.childId);
});

class ChildHomeScreen extends ConsumerWidget {
  final String childId;
  const ChildHomeScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final childAsync = ref.watch(_childProvider(childId));
    final progressAsync = user == null
        ? const AsyncValue<ProgressModel>.loading()
        : ref.watch(
            _progressStreamProvider((parentId: user.uid, childId: childId)),
          );

    return Scaffold(
      appBar: AppBar(
        title: childAsync.maybeWhen(
          data: (c) => Text(c?.name ?? 'Child Home'),
          orElse: () => const Text('Child Home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.store_outlined),
            tooltip: 'Rewards Shop',
            onPressed: () => context.go('/shop/$childId'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings/$childId'),
          ),
        ],
      ),
      body: childAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (child) {
          if (child == null) {
            return const Center(child: Text('Child not found'));
          }
          return progressAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (progress) => _ChildHomeBody(child: child, progress: progress),
          );
        },
      ),
    );
  }
}

class _ChildHomeBody extends StatelessWidget {
  final ChildModel child;
  final ProgressModel progress;

  const _ChildHomeBody({required this.child, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      child: Text(
                        child.name.isNotEmpty
                            ? child.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${child.name}! 👋',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Level ${progress.level} · ${progress.xp} XP',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Stats row
            Row(
              children: [
                _StatChip(
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                  label: '${progress.streakCount} day streak',
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.monetization_on,
                  color: Colors.amber,
                  label: '${progress.coins} coins',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // XP progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${progress.level} Progress',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _levelProgress(progress.xp, progress.level),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
            const Spacer(),
            // Start Quiz button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: FilledButton.icon(
                onPressed: () => context.go('/quiz/${child.id}'),
                icon: const Icon(Icons.play_arrow, size: 32),
                label: const Text(
                  'Start Quiz!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/children'),
                icon: const Icon(Icons.switch_account),
                label: const Text('Switch Child'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _levelProgress(int xp, int level) {
    if (level >= kLevelThresholds.length) return 1.0;
    final currentThreshold = kLevelThresholds[level - 1];
    final nextThreshold = level < kLevelThresholds.length
        ? kLevelThresholds[level]
        : kLevelThresholds.last + 1000;
    final range = nextThreshold - currentThreshold;
    if (range <= 0) return 1.0;
    return (xp - currentThreshold) / range;
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _StatChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
