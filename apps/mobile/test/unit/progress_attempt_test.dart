import 'package:flutter_test/flutter_test.dart';
import 'package:edugate/shared/models/progress_model.dart';

void main() {
  group('ProgressModel.applyAttempt', () {
    test('increments daily count for correct answer', () {
      final progress = ProgressModel(childId: 'c1');
      final now = DateTime(2024, 1, 15);
      final updated = progress.applyAttempt(isCorrect: true, now: now);
      expect(updated.dailyAttemptsToday, 1);
      expect(updated.xp, kXpPerCorrect);
      expect(updated.coins, kCoinsPerCorrect);
    });

    test('increments daily count for incorrect answer', () {
      final progress = ProgressModel(childId: 'c1');
      final now = DateTime(2024, 1, 15);
      final updated = progress.applyAttempt(isCorrect: false, now: now);
      expect(updated.dailyAttemptsToday, 1);
      expect(updated.xp, 0);
      expect(updated.coins, 0);
    });

    test('incorrect answers count toward daily minimum for streak', () {
      final day1 = DateTime(2024, 1, 15);
      final day2 = DateTime(2024, 1, 16);
      ProgressModel progress = ProgressModel(childId: 'c1');

      // Day 1: meet minimum with a mix of correct and incorrect
      for (var i = 0; i < kDailyMinAttempts; i++) {
        progress = progress.applyAttempt(isCorrect: i % 2 == 0, now: day1);
      }
      expect(progress.streakCount, 1);

      // Day 2: meet minimum with all incorrect
      for (var i = 0; i < kDailyMinAttempts; i++) {
        progress = progress.applyAttempt(isCorrect: false, now: day2);
      }
      expect(progress.streakCount, 2);
    });

    test('only awards XP and coins for correct answers', () {
      final now = DateTime(2024, 1, 15);
      ProgressModel progress = ProgressModel(childId: 'c1');

      progress = progress.applyAttempt(isCorrect: false, now: now);
      expect(progress.xp, 0);
      expect(progress.coins, 0);

      progress = progress.applyAttempt(isCorrect: true, now: now);
      expect(progress.xp, kXpPerCorrect);
      expect(progress.coins, kCoinsPerCorrect);

      progress = progress.applyAttempt(isCorrect: false, now: now);
      expect(progress.xp, kXpPerCorrect);
      expect(progress.coins, kCoinsPerCorrect);
    });

    test('resets daily count on new day', () {
      final day1 = DateTime(2024, 1, 15);
      final day2 = DateTime(2024, 1, 16);
      ProgressModel progress = ProgressModel(childId: 'c1');

      for (var i = 0; i < 3; i++) {
        progress = progress.applyAttempt(isCorrect: true, now: day1);
      }
      expect(progress.dailyAttemptsToday, 3);

      progress = progress.applyAttempt(isCorrect: true, now: day2);
      expect(progress.dailyAttemptsToday, 1);
    });
  });
}
