class MarketModel {
  final String id;
  final String marketName;
  final String createdBy; // Kierownik userId
  final bool isDeleted;
  final DateTime insertedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  MarketModel({
    required this.id,
    required this.marketName,
    required this.createdBy,
    this.isDeleted = false,
    required this.insertedAt,
    required this.updatedAt,
    this.deletedAt,
  });
  static MarketModel empty() =>MarketModel(id: "", marketName: "", createdBy: "", insertedAt: DateTime.now(), updatedAt: DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marketName': marketName,
      'createdBy': createdBy,
      'isDeleted': isDeleted,
      'insertedAt': insertedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory MarketModel.fromMap(Map<String, dynamic> map) {
    return MarketModel(
      id: map['id'] ?? '',
      marketName: map['marketName'] ?? '',
      createdBy: map['createdBy'] ?? '',
      isDeleted: map['isDeleted'] ?? false,
      insertedAt: DateTime.parse(map['insertedAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
    );
  }

  // Copy with method for updates
  MarketModel copyWith({
    String? marketName,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return MarketModel(
      id: id,
      marketName: marketName ?? this.marketName,
      createdBy: createdBy,
      isDeleted: isDeleted ?? this.isDeleted,
      insertedAt: insertedAt,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
