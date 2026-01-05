import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleModel {
  // basic fields
  final DateTime shiftDate;
  final String employeeID;
  final String employeeFirstName;
  final String employeeLastName;
  final TimeOfDay start;
  final TimeOfDay end;
  final int duration;
  final List<String> tags;

  // NOWE POLA
  final int monthOfUsage;
  final int yearOfUsage;
  final DateTime? publishedAt;

  // general repeated fields
  final bool? isDataMissing;
  final bool isDeleted;
  final DateTime insertedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Opcjonalnie: ID dokumentu, przydaje się przy pobieraniu
  final String? id;

  ScheduleModel({
    this.id,
    required this.shiftDate,
    required this.employeeID,
    required this.employeeFirstName,
    required this.employeeLastName,
    required this.start,
    required this.end,
    required this.duration,
    required this.tags,
    required this.monthOfUsage, // <---
    required this.yearOfUsage,  // <---
    this.publishedAt,
    this.isDeleted = false,
    this.isDataMissing = false,
    required this.insertedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  static ScheduleModel empty() {
    final now = DateTime.now();
    return ScheduleModel(
      id: '',
      shiftDate: now,
      employeeID: "",
      employeeFirstName: '',
      employeeLastName: '',
      start: TimeOfDay.now(),
      end: TimeOfDay.now(),
      duration: 0,
      tags: [],
      monthOfUsage: now.month,
      yearOfUsage: now.year,
      insertedAt: now,
      isDataMissing: false,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shiftDate': shiftDate.toIso8601String(),
      'employeeID': employeeID,
      'employeeFirstName': employeeFirstName,
      'employeeLastName': employeeLastName,
      'start': '${start.hour}:${start.minute}',
      'end': '${end.hour}:${end.minute}',
      'duration': duration,
      'tags': tags,
      // Mapowanie na nazwy z Firestore
      'month_of_usage': monthOfUsage,
      'year_of_usage': yearOfUsage,
      'isDataMissing': isDataMissing,
      'isDeleted': isDeleted,
      'insertedAt': insertedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory ScheduleModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return ScheduleModel.empty();

    DateTime? parseDateTimeNullable(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    DateTime parseDateTime(dynamic value) {
      return parseDateTimeNullable(value) ?? DateTime.now();
    }

    TimeOfDay parseTime(dynamic value) {
      if (value is String && value.contains(':')) {
        final parts = value.split(':');
        return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
      return TimeOfDay.now();
    }

    final shiftDateParsed = parseDateTime(data['shiftDate']);

    return ScheduleModel(
      id: doc.id,
      shiftDate: shiftDateParsed,

      employeeID: data['employeeID'] as String? ?? '',
      employeeFirstName: data['employeeFirstName'] as String? ?? '',
      employeeLastName: data['employeeLastName'] as String? ?? '',

      start: parseTime(data['start']),
      end: parseTime(data['end']),

      duration: (data['duration'] as num?)?.toInt() ?? 0,
      tags: List<String>.from(data['tags'] ?? []),

      monthOfUsage: (data['month_of_usage'] as int?) ?? shiftDateParsed.month,
      yearOfUsage: (data['year_of_usage'] as int?) ?? shiftDateParsed.year,

      isDataMissing: data['isDataMissing'] ?? false,
      isDeleted: data['isDeleted'] ?? false,

      insertedAt: parseDateTime(data['insertedAt']),
      updatedAt: parseDateTime(data['updatedAt']),

      publishedAt: parseDateTimeNullable(data['publishedAt']),

      deletedAt: parseDateTimeNullable(data['deletedAt']),
    );
  }

  ScheduleModel copyWith({
    String? id,
    DateTime? shiftDate,
    String? employeeID,
    String? employeeFirstName,
    String? employeeLastName,
    TimeOfDay? start,
    TimeOfDay? end,
    int? duration,
    List<String>? tags,
    int? monthOfUsage,
    int? yearOfUsage,
    bool? isDataMissing,
    bool? isDeleted,
    DateTime? insertedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      shiftDate: shiftDate ?? this.shiftDate,
      employeeID: employeeID ?? this.employeeID,
      employeeFirstName: employeeFirstName ?? this.employeeFirstName,
      employeeLastName: employeeLastName ?? this.employeeLastName,
      start: start ?? this.start,
      end: end ?? this.end,
      duration: duration ?? this.duration,
      tags: tags ?? this.tags,
      monthOfUsage: monthOfUsage ?? this.monthOfUsage,
      yearOfUsage: yearOfUsage ?? this.yearOfUsage,
      isDataMissing: isDataMissing ?? this.isDataMissing,
      isDeleted: isDeleted ?? this.isDeleted,
      insertedAt: insertedAt ?? this.insertedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}