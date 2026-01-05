import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleDocumentModel {
  final String id;
  final String marketId;
  final String templateUsed;
  final String createdBy;
  final DateTime createdAt;
  final int yearOfUsage;
  final int monthOfUsage;
  final int daysInMonth;
  final bool isCurrentlyPublished;
  final Map<String, dynamic> generatedSchedule; // dane z algorytmu zparsowane z powrotem do mapy

  ScheduleDocumentModel({
    required this.id,
    required this.marketId,
    required this.templateUsed,
    required this.createdBy,
    required this.createdAt,
    required this.yearOfUsage,
    required this.monthOfUsage,
    required this.daysInMonth,
    this.isCurrentlyPublished = false,
    required this.generatedSchedule
  });

  factory ScheduleDocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ScheduleDocumentModel(
      id: doc.id,
      marketId: data['market_id'] ?? '',
      templateUsed: data['templateUsed'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      yearOfUsage: data['year_of_usage'] ?? DateTime.now().year,
      monthOfUsage: data['month_of_usage'] ?? DateTime.now().month,
      daysInMonth: data['days_in_month'] ?? 31,
      isCurrentlyPublished: data['isCurrentlyPublished'] ?? false,
      generatedSchedule: data['generated_schedule'] ?? {},

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'market_id': marketId,
      'templateUsed': templateUsed,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'year_of_usage': yearOfUsage,
      'month_of_usage': monthOfUsage,
      'days_in_month': daysInMonth,
      'isCurrentlyPublished': isCurrentlyPublished,
      'generated_schedule': generatedSchedule,
    };
  }

  ScheduleDocumentModel copyWith({
    bool? isCurrentlyPublished,
    Map<String, dynamic>? generatedSchedule,
  }) {
    return ScheduleDocumentModel(
      id: id,
      marketId: marketId,
      templateUsed: templateUsed,
      createdBy: createdBy,
      createdAt: createdAt,
      yearOfUsage: yearOfUsage,
      monthOfUsage: monthOfUsage,
      daysInMonth: daysInMonth,
      isCurrentlyPublished: isCurrentlyPublished ?? this.isCurrentlyPublished,
      generatedSchedule: generatedSchedule ?? this.generatedSchedule,
    );
  }
}