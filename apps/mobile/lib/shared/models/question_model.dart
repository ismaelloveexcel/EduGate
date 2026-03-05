// lib/shared/models/question_model.dart
import 'package:equatable/equatable.dart';

enum QuestionType { mcq, trueFalse, fillInNumber }

enum Difficulty { easy, medium, hard }

class QuestionModel extends Equatable {
  final String id;
  final String subject;
  final Difficulty difficulty;
  final QuestionType type;
  final String prompt;
  final List<String> options; // empty for fillInNumber
  final String correctAnswer;
  final List<String> tags;

  const QuestionModel({
    required this.id,
    required this.subject,
    required this.difficulty,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    this.tags = const [],
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestionModel(
      id: id,
      subject: map['subject'] as String? ?? '',
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == (map['difficulty'] as String? ?? 'easy'),
        orElse: () => Difficulty.easy,
      ),
      type: QuestionType.values.firstWhere(
        (t) => t.name == (map['type'] as String? ?? 'mcq'),
        orElse: () => QuestionType.mcq,
      ),
      prompt: map['prompt'] as String? ?? '',
      options: List<String>.from(map['options'] as List? ?? []),
      correctAnswer: map['correctAnswer'] as String? ?? '',
      tags: List<String>.from(map['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'difficulty': difficulty.name,
      'type': type.name,
      'prompt': prompt,
      'options': options,
      'correctAnswer': correctAnswer,
      'tags': tags,
    };
  }

  @override
  List<Object?> get props =>
      [id, subject, difficulty, type, prompt, options, correctAnswer, tags];
}
