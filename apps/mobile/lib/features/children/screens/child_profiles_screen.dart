// lib/features/children/screens/child_profiles_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/children_provider.dart';
import '../../../shared/models/child_model.dart';
import '../../auth/providers/auth_provider.dart';

class ChildProfilesScreen extends ConsumerWidget {
  const ChildProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Parent Dashboard',
            onPressed: () => context.go('/dashboard'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/children/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Child'),
      ),
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (children) {
          if (children.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No children added yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => context.go('/children/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Child'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              return _ChildCard(child: child);
            },
          );
        },
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;
  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(child.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Grade ${child.grade} · Age ${child.age}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.go('/children/edit/${child.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Enter as ${child.name}',
              onPressed: () => context.go('/pin/${child.id}'),
            ),
          ],
        ),
        onTap: () => context.go('/pin/${child.id}'),
      ),
    );
  }
}
