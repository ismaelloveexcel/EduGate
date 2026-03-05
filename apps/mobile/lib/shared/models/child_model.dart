// lib/shared/models/child_model.dart
import 'package:equatable/equatable.dart';

class ChildModel extends Equatable {
  final String id;
  final String parentId;
  final String name;
  final int age;
  final String grade;
  final String pinHash;
  final String avatarId;
  final DateTime createdAt;
  final List<String> subjectsEnabled;
  final int quizIntervalMinutes;
  final int quietHoursStart; // 0-23
  final int quietHoursEnd;   // 0-23

  const ChildModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.age,
    required this.grade,
    required this.pinHash,
    required this.avatarId,
    required this.createdAt,
    this.subjectsEnabled = const ['math', 'science', 'english'],
    this.quizIntervalMinutes = 30,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 7,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map, String id) {
    return ChildModel(
      id: id,
      parentId: map['parentId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      age: map['age'] as int? ?? 0,
      grade: map['grade'] as String? ?? '',
      pinHash: map['pinHash'] as String? ?? '',
      avatarId: map['avatarId'] as String? ?? 'avatar_1',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      subjectsEnabled: List<String>.from(
          map['subjectsEnabled'] as List? ?? ['math', 'science', 'english']),
      quizIntervalMinutes: map['quizIntervalMinutes'] as int? ?? 30,
      quietHoursStart: map['quietHoursStart'] as int? ?? 22,
      quietHoursEnd: map['quietHoursEnd'] as int? ?? 7,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'name': name,
      'age': age,
      'grade': grade,
      'pinHash': pinHash,
      'avatarId': avatarId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'subjectsEnabled': subjectsEnabled,
      'quizIntervalMinutes': quizIntervalMinutes,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  ChildModel copyWith({
    String? id,
    String? parentId,
    String? name,
    int? age,
    String? grade,
    String? pinHash,
    String? avatarId,
    DateTime? createdAt,
    List<String>? subjectsEnabled,
    int? quizIntervalMinutes,
    int? quietHoursStart,
    int? quietHoursEnd,
  }) {
    return ChildModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      age: age ?? this.age,
      grade: grade ?? this.grade,
      pinHash: pinHash ?? this.pinHash,
      avatarId: avatarId ?? this.avatarId,
      createdAt: createdAt ?? this.createdAt,
      subjectsEnabled: subjectsEnabled ?? this.subjectsEnabled,
      quizIntervalMinutes: quizIntervalMinutes ?? this.quizIntervalMinutes,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  @override
  List<Object?> get props => [
        id,
        parentId,
        name,
        age,
        grade,
        pinHash,
        avatarId,
        createdAt,
        subjectsEnabled,
        quizIntervalMinutes,
        quietHoursStart,
        quietHoursEnd,
      ];
}
