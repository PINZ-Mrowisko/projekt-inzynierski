import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_basics/features/templates/models/template_shift_model.dart';

class TemplateModel {
  final String id;
  final String templateName;
  final String description;
  final String marketId;
  final int? minWomen;
  final int? maxWomen;
  final int? minMen;
  final int? maxMen;
  final bool? isDataMissing; // this field will be used with tag management; if tag is deleted data will be missing
  final bool isDeleted;
  final DateTime insertedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<ShiftModel>? shifts;

  TemplateModel( {
    required this.id,
    required this.templateName,
    required this.description,
    required this.marketId,
    this.minWomen,
    this.maxWomen,
    this.minMen,
    this.maxMen,
    this.isDeleted = false,
    this.isDataMissing = false,
    required this.insertedAt,
    required this.updatedAt,
    this.deletedAt,
    this.shifts,
  });

  static TemplateModel empty() => TemplateModel(
    id: "",
    templateName: '',
    description: '',
    marketId: '',
    insertedAt: DateTime.now(),
    isDataMissing: false,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateName': templateName,
      'description': description,
      'marketId': marketId,
      'minWomen': minWomen,
      'maxWomen': maxWomen,
      'minMen': minMen,
      'maxMen': maxMen,
      'isDataMissing': isDataMissing,
      'isDeleted': isDeleted,
      'insertedAt': insertedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory TemplateModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return TemplateModel.empty();

    return TemplateModel(
      id: data['id'] ?? doc.id,
      templateName: data['templateName'] ?? '',
      description: data['description'] ?? '',
      marketId: data['marketId'] ?? '',
      minWomen: data['minWomen'],
      maxWomen: data['maxWomen'],
      minMen: data['minMen'],
      maxMen: data['maxMen'],
      isDataMissing: data['isDataMissing'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      insertedAt: DateTime.parse(data['insertedAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      deletedAt:
      data['deletedAt'] != null ? DateTime.parse(data['deletedAt']) : null,
    );
  }

  TemplateModel copyWith({
    String? id,
    String? templateName,
    String? description,
    String? marketId,
    String? kierownikId,
    int? minWomen,
    int? maxWomen,
    int? minMen,
    int? maxMen,
    bool? isDataMissing,
    bool? isDeleted,
    DateTime? insertedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<ShiftModel>? shifts,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      templateName: templateName ?? this.templateName,
      description: description ?? this.description,
      marketId: marketId ?? this.marketId,
      minWomen: minWomen ?? this.minWomen,
      maxWomen: maxWomen ?? this.maxWomen,
      minMen: minMen ?? this.minMen,
      maxMen: maxMen ?? this.maxMen,
      isDataMissing: isDataMissing ?? this.isDataMissing,
      isDeleted: isDeleted ?? this.isDeleted,
      insertedAt: insertedAt ?? this.insertedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      shifts: shifts ?? this.shifts,
    );
  }
}
