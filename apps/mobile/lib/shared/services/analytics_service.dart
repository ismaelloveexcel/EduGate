import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logSignUp() => _analytics.logSignUp(signUpMethod: 'email');

  Future<void> logLogin() => _analytics.logLogin(loginMethod: 'email');

  Future<void> logChildCreated({required String childId}) =>
      _analytics.logEvent(name: 'child_created', parameters: {
        'child_id': childId,
      });

  Future<void> logQuizStarted({
    required String childId,
    required int questionCount,
  }) =>
      _analytics.logEvent(name: 'quiz_started', parameters: {
        'child_id': childId,
        'question_count': questionCount,
      });

  Future<void> logQuizCompleted({
    required String childId,
    required int correct,
    required int total,
  }) =>
      _analytics.logEvent(name: 'quiz_completed', parameters: {
        'child_id': childId,
        'correct': correct,
        'total': total,
        'accuracy': total > 0 ? (correct / total * 100).round() : 0,
      });

  Future<void> logLevelUp({
    required String childId,
    required int newLevel,
  }) =>
      _analytics.logEvent(name: 'level_up', parameters: {
        'child_id': childId,
        'new_level': newLevel,
      });

  Future<void> logStreakAchieved({
    required String childId,
    required int streakCount,
  }) =>
      _analytics.logEvent(name: 'streak_achieved', parameters: {
        'child_id': childId,
        'streak_count': streakCount,
      });

  Future<void> logPurchase({
    required String childId,
    required String itemId,
    required int coinCost,
  }) =>
      _analytics.logEvent(name: 'cosmetic_purchase', parameters: {
        'child_id': childId,
        'item_id': itemId,
        'coin_cost': coinCost,
      });
}
