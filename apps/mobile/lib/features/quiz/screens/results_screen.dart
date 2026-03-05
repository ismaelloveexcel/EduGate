// lib/features/quiz/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultsScreen extends StatelessWidget {
  final String childId;
  final int correctCount;
  final int totalCount;
  final int xpEarned;
  final int coinsEarned;

  const ResultsScreen({
    super.key,
    required this.childId,
    required this.correctCount,
    required this.totalCount,
    required this.xpEarned,
    required this.coinsEarned,
  });

  double get _accuracy => totalCount == 0 ? 0 : correctCount / totalCount;

  @override
  Widget build(BuildContext context) {
    final emoji = _accuracy >= 0.8 ? '🎉' : _accuracy >= 0.5 ? '👍' : '💪';
    final message = _accuracy >= 0.8
        ? 'Outstanding!'
        : _accuracy >= 0.5
            ? 'Good job!'
            : 'Keep practising!';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              // Score card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _ResultRow(
                        label: 'Score',
                        value: '$correctCount / $totalCount',
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      const Divider(),
                      _ResultRow(
                        label: 'Accuracy',
                        value: '${(_accuracy * 100).toStringAsFixed(0)}%',
                        icon: Icons.percent,
                        color: Colors.blue,
                      ),
                      const Divider(),
                      _ResultRow(
                        label: 'XP Earned',
                        value: '+$xpEarned XP',
                        icon: Icons.star_outline,
                        color: Colors.purple,
                      ),
                      const Divider(),
                      _ResultRow(
                        label: 'Coins Earned',
                        value: '+$coinsEarned 🪙',
                        icon: Icons.monetization_on_outlined,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.go('/quiz/$childId'),
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/child-home/$childId'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
