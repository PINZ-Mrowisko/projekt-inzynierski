import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleModel {
  // basic fields we will use in displaying
  final DateTime shiftDate;
  final String employeeID;
  final String employeeFirstName;
  final String employeeLastName;
  final TimeOfDay start;
  final TimeOfDay end;
  final int duration; // this field we can use to calculate the hours of each employee monthly
  final List<String> tags; // just a list of strings to display them in view, dont really need any fancy maps

  // general repeated fields
  final bool? isDataMissing;
  final bool isDeleted;
  final DateTime insertedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ScheduleModel({
    required this.shiftDate,
    required this.employeeID,
    required this.employeeFirstName,
    required this.employeeLastName,
    required this.start,
    required this.end,
    required this.duration,
    required this.tags,
    this.isDeleted = false,
    this.isDataMissing = false,
    required this.insertedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  static ScheduleModel empty() => ScheduleModel(
    shiftDate: DateTime.now(),
    employeeID: "",
    employeeFirstName: '',
    employeeLastName: '',
    start: TimeOfDay.now(),
    end: TimeOfDay.now(),
    duration: 0,
    tags: [],
    insertedAt: DateTime.now(),
    isDataMissing: false,
    updatedAt: DateTime.now(),
  );

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
      'isDataMissing': isDataMissing,
      'isDeleted': isDeleted,
      'insertedAt': insertedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory ScheduleModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return ScheduleModel.empty();

    TimeOfDay parseTime(String timeString) {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return ScheduleModel(
      shiftDate: DateTime.parse(data['shiftDate'] ?? DateTime.now().toIso8601String()),
      employeeID: data['employeeID'] ?? '',
      employeeFirstName: data['employeeFirstName'] ?? '',
      employeeLastName: data['employeeLastName'] ?? '',
      start: data['start'] != null ? parseTime(data['start']) : TimeOfDay.now(),
      end: data['end'] != null ? parseTime(data['end']) : TimeOfDay.now(),
      duration: data['duration'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      isDataMissing: data['isDataMissing'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      insertedAt: DateTime.parse(data['insertedAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      deletedAt: data['deletedAt'] != null ? DateTime.parse(data['deletedAt']) : null,
    );
  }

  ScheduleModel copyWith({
    DateTime? shiftDate,
    String? employeeID,
    String? employeeFirstName,
    String? employeeLastName,
    TimeOfDay? start,
    TimeOfDay? end,
    int? duration,
    List<String>? tags,
    bool? isDataMissing,
    bool? isDeleted,
    DateTime? insertedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ScheduleModel(
      shiftDate: shiftDate ?? this.shiftDate,
      employeeID: employeeID ?? this.employeeID,
      employeeFirstName: employeeFirstName ?? this.employeeFirstName,
      employeeLastName: employeeLastName ?? this.employeeLastName,
      start: start ?? this.start,
      end: end ?? this.end,
      duration: duration ?? this.duration,
      tags: tags ?? this.tags,
      isDataMissing: isDataMissing ?? this.isDataMissing,
      isDeleted: isDeleted ?? this.isDeleted,
      insertedAt: insertedAt ?? this.insertedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}