// test/unit/progress_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:edugate/shared/models/progress_model.dart';
import 'package:edugate/shared/models/question_model.dart';

void main() {
  group('ProgressModel', () {
    test('computeLevel returns 1 for 0 XP', () {
      expect(computeLevel(0), 1);
    });

    test('computeLevel returns 2 at 100 XP threshold', () {
      expect(computeLevel(100), 2);
    });

    test('computeLevel returns 3 at 250 XP threshold', () {
      expect(computeLevel(250), 3);
    });

    test('computeLevel returns 10 at max threshold', () {
      expect(computeLevel(4500), 10);
    });

    test('computeLevel caps at max level for large XP', () {
      expect(computeLevel(99999), 10);
    });

    test('applyCorrectAnswer increments XP by kXpPerCorrect', () {
      final progress = ProgressModel(childId: 'c1');
      final now = DateTime(2024, 1, 15);
      final updated = progress.applyCorrectAnswer(now: now);
      expect(updated.xp, kXpPerCorrect);
    });

    test('applyCorrectAnswer increments coins by kCoinsPerCorrect', () {
      final progress = ProgressModel(childId: 'c1');
      final now = DateTime(2024, 1, 15);
      final updated = progress.applyCorrectAnswer(now: now);
      expect(updated.coins, kCoinsPerCorrect);
    });

    test('applyCorrectAnswer updates level based on new XP', () {
      // Start at level 1, add enough XP to reach level 2
      const int xpNeeded = 100; // kLevelThresholds[1]
      final repetitions = xpNeeded ~/ kXpPerCorrect;

      ProgressModel progress = ProgressModel(childId: 'c1');
      final now = DateTime(2024, 1, 15);

      for (var i = 0; i < repetitions; i++) {
        progress = progress.applyCorrectAnswer(now: now);
      }

      expect(progress.xp, xpNeeded);
      expect(progress.level, 2);
    });

    test('streak increments when daily minimum met on consecutive days', () {
      final day1 = DateTime(2024, 1, 15);
      final day2 = DateTime(2024, 1, 16);

      ProgressModel progress = ProgressModel(childId: 'c1');

      // Day 1: meet the minimum
      for (var i = 0; i < kDailyMinAttempts; i++) {
        progress = progress.applyCorrectAnswer(now: day1);
      }
      // After meeting minimum on day1, streak should be 1
      expect(progress.streakCount, equals(1));

      // Day 2: meet the minimum again
      for (var i = 0; i < kDailyMinAttempts; i++) {
        progress = progress.applyCorrectAnswer(now: day2);
      }
      // After meeting minimum on day2 (consecutive), streak should be 2
      expect(progress.streakCount, equals(2));
    });

    test('streak does not increment if called twice on same day (below minimum)', () {
      final day = DateTime(2024, 1, 15);
      ProgressModel progress = ProgressModel(childId: 'c1', streakCount: 3);

      // Only 1 correct answer on this day (below minimum of 5)
      progress = progress.applyCorrectAnswer(now: day);
      // Streak should not increase yet
      expect(progress.streakCount, 3);
    });

    test('adaptiveDifficulty raises difficulty above 80% accuracy', () {
      final progress = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'easy'},
      );
      final result = progress.adaptiveDifficulty('math', 0.9);
      expect(result, Difficulty.medium);
    });

    test('adaptiveDifficulty lowers difficulty below 50% accuracy', () {
      final progress = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'hard'},
      );
      final result = progress.adaptiveDifficulty('math', 0.3);
      expect(result, Difficulty.medium);
    });

    test('adaptiveDifficulty keeps difficulty unchanged for 50–80% accuracy', () {
      final progress = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'medium'},
      );
      final result = progress.adaptiveDifficulty('math', 0.65);
      expect(result, Difficulty.medium);
    });

    test('adaptiveDifficulty does not go above hard', () {
      final progress = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'hard'},
      );
      final result = progress.adaptiveDifficulty('math', 0.95);
      expect(result, Difficulty.hard);
    });

    test('adaptiveDifficulty does not go below easy', () {
      final progress = ProgressModel(
        childId: 'c1',
        difficultyBySubject: {'math': 'easy'},
      );
      final result = progress.adaptiveDifficulty('math', 0.2);
      expect(result, Difficulty.easy);
    });

    test('adaptiveDifficulty defaults to easy for unknown subject', () {
      final progress = ProgressModel(childId: 'c1');
      final result = progress.adaptiveDifficulty('unknown_subject', 0.2);
      expect(result, Difficulty.easy);
    });
  });
}
