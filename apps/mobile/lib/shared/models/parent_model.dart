// lib/shared/models/parent_model.dart
import 'package:equatable/equatable.dart';

class ParentModel extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final List<String> childIds;
  /// Device FCM tokens — supports multiple devices per parent.
  final List<String> fcmTokens;

  const ParentModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.childIds = const [],
    this.fcmTokens = const [],
  });

  factory ParentModel.fromMap(Map<String, dynamic> map, String id) {
    return ParentModel(
      id: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['createdAt'] as int),
            )
          : DateTime.now(),
      childIds: List<String>.from(map['childIds'] as List? ?? []),
      fcmTokens: List<String>.from(map['fcmTokens'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'childIds': childIds,
      'fcmTokens': fcmTokens,
    };
  }

  ParentModel copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    List<String>? childIds,
    List<String>? fcmTokens,
  }) {
    return ParentModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      childIds: childIds ?? this.childIds,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, displayName, createdAt, childIds, fcmTokens];
}
