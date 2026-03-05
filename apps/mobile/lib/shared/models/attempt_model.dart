// lib/shared/models/attempt_model.dart
import 'package:equatable/equatable.dart';
import 'question_model.dart';

class AttemptModel extends Equatable {
  final String id;
  final String childId;
  final String questionId;
  final String subject;
  final Difficulty difficulty;
  final QuestionType type;
  final bool isCorrect;
  final int timeTakenMs;
  final DateTime createdAt;

  const AttemptModel({
    required this.id,
    required this.childId,
    required this.questionId,
    required this.subject,
    required this.difficulty,
    required this.type,
    required this.isCorrect,
    required this.timeTakenMs,
    required this.createdAt,
  });

  factory AttemptModel.fromMap(Map<String, dynamic> map, String id) {
    return AttemptModel(
      id: id,
      childId: map['childId'] as String? ?? '',
      questionId: map['questionId'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == (map['difficulty'] as String? ?? 'easy'),
        orElse: () => Difficulty.easy,
      ),
      type: QuestionType.values.firstWhere(
        (t) => t.name == (map['type'] as String? ?? 'mcq'),
        orElse: () => QuestionType.mcq,
      ),
      isCorrect: map['isCorrect'] as bool? ?? false,
      timeTakenMs: map['timeTakenMs'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'questionId': questionId,
      'subject': subject,
      'difficulty': difficulty.name,
      'type': type.name,
      'isCorrect': isCorrect,
      'timeTakenMs': timeTakenMs,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        questionId,
        subject,
        difficulty,
        type,
        isCorrect,
        timeTakenMs,
        createdAt,
      ];
}
