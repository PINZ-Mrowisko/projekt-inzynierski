import 'package:cloud_firestore/cloud_firestore.dart';

class TagsModel {
  final String id;
  final String tagName;
  final String description;
  final String marketId;
  final bool isDeleted;
  final DateTime insertedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  TagsModel({
    required this.id,
    required this.tagName,
    required this.description,
    required this.marketId,
    this.isDeleted = false,
    required this.insertedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  static TagsModel empty() => TagsModel(
    id: "",
    tagName: '',
    description: '',
    marketId: '',
    insertedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagName': tagName,
      'description': description,
      'marketId': marketId,
      'isDeleted': isDeleted,
      'insertedAt': insertedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory TagsModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() != null) {
      final map = doc.data()!;
      return TagsModel(
        id: map['id'] ?? '',
        tagName: map['tagName'] ?? '',
        description: map['description'] ?? '',
        marketId: map['marketId'] ?? '',
        isDeleted: map['isDeleted'] ?? false,
        insertedAt: DateTime.parse(map['insertedAt']),
        updatedAt: DateTime.parse(map['updatedAt']),
        deletedAt:
            map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
      );
    } else {
      return TagsModel.empty();
    }
  }

  TagsModel copyWith({
    String? tagName,
    String? description,
    String? marketId,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return TagsModel(
      id: id,
      tagName: tagName ?? this.tagName,
      description: description ?? this.description,
      marketId: marketId ?? this.marketId,
      isDeleted: isDeleted ?? this.isDeleted,
      insertedAt: insertedAt,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
