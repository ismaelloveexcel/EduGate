// lib/features/dashboard/screens/parent_dashboard_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/progress_repository.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/attempt_model.dart';
import '../../../shared/models/progress_key.dart';
import '../../../shared/models/progress_model.dart';
import '../../children/providers/children_provider.dart';

final _dashProgressStreamProvider =
    StreamProvider.family<ProgressModel, ProgressKey>((ref, key) {
  return ref
      .read(progressRepositoryProvider)
      .watchProgress(key.parentId, key.childId);
});

typedef _ChartKey = ({String parentId, String childId});
final _last7DaysAttemptsProvider =
    FutureProvider.family<List<AttemptModel>, _ChartKey>((ref, key) {
  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 7));
  return ref.read(progressRepositoryProvider).getAttemptsForDateRange(
    key.parentId, key.childId, from: from, to: now,
  );
});

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        leading: BackButton(onPressed: () => context.go('/children')),
      ),
      body: ref.watch(childrenStreamProvider).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (children) {
          if (children.isEmpty) {
            return const Center(child: Text('No children added yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, i) => _ChildDashboardCard(child: children[i]),
          );
        },
      ),
    );
  }
}

class _ChildDashboardCard extends ConsumerWidget {
  final ChildModel child;
  const _ChildDashboardCard({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(
      _dashProgressStreamProvider(
          (parentId: child.parentId, childId: child.id)),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(child.name[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Text(
                  child.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/settings/${child.id}'),
                  child: const Text('Settings'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            progressAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (progress) => _ProgressStats(progress: progress),
            ),
            const SizedBox(height: 12),
            _Last7DaysChart(parentId: child.parentId, childId: child.id),
          ],
        ),
      ),
    );
  }
}

class _ProgressStats extends StatelessWidget {
  final ProgressModel progress;
  const _ProgressStats({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _StatBadge(label: 'Level', value: '${progress.level}', icon: Icons.emoji_events),
        _StatBadge(label: 'XP', value: '${progress.xp}', icon: Icons.star),
        _StatBadge(label: 'Coins', value: '${progress.coins}', icon: Icons.monetization_on),
        _StatBadge(label: 'Streak', value: '${progress.streakCount}d', icon: Icons.local_fire_department),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBadge({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text('$label: $value', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Last7DaysChart extends ConsumerWidget {
  final String parentId;
  final String childId;
  const _Last7DaysChart({required this.parentId, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final attemptsAsync = ref.watch(
      _last7DaysAttemptsProvider((parentId: parentId, childId: childId)),
    );

    return attemptsAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Error: $e'),
      data: (attempts) {
        if (attempts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No attempts in last 7 days.',
                style: TextStyle(color: Colors.grey)),
          );
        }

        final Map<int, List<AttemptModel>> byDay = {};
        for (var i = 0; i < 7; i++) {
          byDay[i] = [];
        }
        for (final a in attempts) {
          final daysAgo = now
              .difference(a.createdAt)
              .inDays
              .clamp(0, 6);
          byDay[6 - daysAgo]!.add(a);
        }

        final spots = byDay.entries.map((e) {
          final dayAttempts = e.value;
          final accuracy = dayAttempts.isEmpty
              ? 0.0
              : dayAttempts.where((a) => a.isCorrect).length /
                  dayAttempts.length;
          return FlSpot(e.key.toDouble(), accuracy * 100);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 7 Days Accuracy',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                            style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final day = now.subtract(
                              Duration(days: (6 - v.toInt())));
                          return Text('${day.month}/${day.day}',
                              style: const TextStyle(fontSize: 9));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
