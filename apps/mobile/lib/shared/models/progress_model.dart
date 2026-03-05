// lib/shared/models/progress_model.dart
import 'package:equatable/equatable.dart';
import 'question_model.dart';

const int kXpPerCorrect = 10;
const int kCoinsPerCorrect = 10;
const int kDailyMinAttempts = 5;

/// Level thresholds: level = index + 1
const List<int> kLevelThresholds = [
  0,    // Level 1
  100,  // Level 2
  250,  // Level 3
  500,  // Level 4
  900,  // Level 5
  1400, // Level 6
  2000, // Level 7
  2700, // Level 8
  3500, // Level 9
  4500, // Level 10
];

int computeLevel(int xp) {
  int level = 1;
  for (int i = kLevelThresholds.length - 1; i >= 0; i--) {
    if (xp >= kLevelThresholds[i]) {
      level = i + 1;
      break;
    }
  }
  return level;
}

class ProgressModel extends Equatable {
  final String childId;
  final int xp;
  final int level;
  final int coins;
  final int streakCount;

  /// The last date the daily minimum [kDailyMinAttempts] was reached.
  /// Used exclusively for streak tracking.
  final DateTime? lastMinMetDate;

  /// The last date any correct answer was recorded.
  /// Used to detect whether we are on a new calendar day (resets daily count).
  final DateTime? lastAttemptDate;

  final int dailyAttemptsToday;

  /// Map of subject -> Difficulty name (adaptive difficulty per subject)
  final Map<String, String> difficultyBySubject;

  const ProgressModel({
    required this.childId,
    this.xp = 0,
    this.level = 1,
    this.coins = 0,
    this.streakCount = 0,
    this.lastMinMetDate,
    this.lastAttemptDate,
    this.dailyAttemptsToday = 0,
    this.difficultyBySubject = const {},
  });

  /// Backwards-compatible alias for [lastMinMetDate].
  DateTime? get lastActiveDate => lastMinMetDate;

  factory ProgressModel.fromMap(Map<String, dynamic> map, String childId) {
    return ProgressModel(
      childId: childId,
      xp: map['xp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      coins: map['coins'] as int? ?? 0,
      streakCount: map['streakCount'] as int? ?? 0,
      lastMinMetDate: map['lastMinMetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMinMetDate'] as int)
          : (map['lastActiveDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  map['lastActiveDate'] as int)
              : null),
      lastAttemptDate: map['lastAttemptDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastAttemptDate'] as int)
          : null,
      dailyAttemptsToday: map['dailyAttemptsToday'] as int? ?? 0,
      difficultyBySubject: Map<String, String>.from(
          map['difficultyBySubject'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'xp': xp,
      'level': level,
      'coins': coins,
      'streakCount': streakCount,
      'lastMinMetDate': lastMinMetDate?.millisecondsSinceEpoch,
      'lastAttemptDate': lastAttemptDate?.millisecondsSinceEpoch,
      'dailyAttemptsToday': dailyAttemptsToday,
      'difficultyBySubject': difficultyBySubject,
    };
  }

  /// Returns updated ProgressModel after a correct answer.
  ///
  /// - [lastAttemptDate] is updated on EVERY call (detects new calendar day).
  /// - [lastMinMetDate] is updated only when [dailyAttemptsToday] first
  ///   reaches [kDailyMinAttempts] (used for streak tracking).
  /// - [now] is injectable for testing.
  ProgressModel applyCorrectAnswer({DateTime? now}) {
    final today = now ?? DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Determine if this is the first attempt of a new calendar day.
    final lastAttempt = lastAttemptDate != null
        ? DateTime(lastAttemptDate!.year, lastAttemptDate!.month,
            lastAttemptDate!.day)
        : null;
    final isNewDay = lastAttempt == null || todayDate.isAfter(lastAttempt);
    final newDailyAttempts = isNewDay ? 1 : dailyAttemptsToday + 1;

    // Streak: only updated when minimum is first met on this calendar day.
    final previousDayDate = todayDate.subtract(const Duration(days: 1));
    final isFirstTimeMinMet = newDailyAttempts == kDailyMinAttempts;

    int newStreak = streakCount;
    DateTime? newLastMinMetDate = lastMinMetDate;

    if (isFirstTimeMinMet) {
      newLastMinMetDate = today;
      final lastMinMet = lastMinMetDate != null
          ? DateTime(lastMinMetDate!.year, lastMinMetDate!.month,
              lastMinMetDate!.day)
          : null;
      final yesterdayMinWasMet =
          lastMinMet != null && lastMinMet.isAtSameMomentAs(previousDayDate);
      if (yesterdayMinWasMet) {
        newStreak = streakCount + 1;
      } else {
        // First streak ever or day was skipped – start at 1.
        newStreak = 1;
      }
    }

    final newXp = xp + kXpPerCorrect;
    final newCoins = coins + kCoinsPerCorrect;
    final newLevel = computeLevel(newXp);

    return copyWith(
      xp: newXp,
      level: newLevel,
      coins: newCoins,
      streakCount: newStreak,
      lastMinMetDate: newLastMinMetDate,
      lastAttemptDate: today,
      dailyAttemptsToday: newDailyAttempts,
    );
  }

  /// Adaptive difficulty: given recent accuracy for a subject, adjust difficulty.
  Difficulty adaptiveDifficulty(String subject, double recentAccuracy) {
    final current = Difficulty.values.firstWhere(
      (d) => d.name == (difficultyBySubject[subject] ?? 'easy'),
      orElse: () => Difficulty.easy,
    );
    if (recentAccuracy > 0.8 && current != Difficulty.hard) {
      return Difficulty.values[current.index + 1];
    } else if (recentAccuracy < 0.5 && current != Difficulty.easy) {
      return Difficulty.values[current.index - 1];
    }
    return current;
  }

  ProgressModel copyWith({
    String? childId,
    int? xp,
    int? level,
    int? coins,
    int? streakCount,
    DateTime? lastMinMetDate,
    DateTime? lastAttemptDate,
    int? dailyAttemptsToday,
    Map<String, String>? difficultyBySubject,
  }) {
    return ProgressModel(
      childId: childId ?? this.childId,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      streakCount: streakCount ?? this.streakCount,
      lastMinMetDate: lastMinMetDate ?? this.lastMinMetDate,
      lastAttemptDate: lastAttemptDate ?? this.lastAttemptDate,
      dailyAttemptsToday: dailyAttemptsToday ?? this.dailyAttemptsToday,
      difficultyBySubject: difficultyBySubject ?? this.difficultyBySubject,
    );
  }

  @override
  List<Object?> get props => [
        childId,
        xp,
        level,
        coins,
        streakCount,
        lastMinMetDate,
        lastAttemptDate,
        dailyAttemptsToday,
        difficultyBySubject,
      ];
}
