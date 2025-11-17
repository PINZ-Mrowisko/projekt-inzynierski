
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final String userId; // employee ID
  final bool newSchedule; // notify about new schedule including user
  final bool leaveStatus; // notify about leave status changes (accepted/denied) - only for employees
  final bool leaveRequests; // notify manager about new leave requests - only for manager
  final DateTime insertedAt;
  final DateTime updatedAt;

  SettingsModel({
    required this.userId,
    this.newSchedule = true,
    this.leaveStatus = true,
    this.leaveRequests = true,
    required this.insertedAt,
    required this.updatedAt,
  });

  static SettingsModel empty() => SettingsModel(
    userId: '',
    newSchedule: true,
    leaveStatus: true,
    leaveRequests: true,
    insertedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'newSchedule': newSchedule,
      'leaveStatus': leaveStatus,
      'leaveRequests': leaveRequests,
      'insertedAt': insertedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SettingsModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return SettingsModel(
      userId: map['userId'] ?? '',
      newSchedule: map['newSchedule'] ?? true,
      leaveStatus: map['leaveStatus'] ?? true,
      leaveRequests: map['leaveRequests'] ?? true,
      insertedAt: DateTime.parse(map['insertedAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }



  SettingsModel copyWith({
    String? userId,
    bool? newSchedule,
    bool? leaveStatus,
    bool? leaveRequests,
    DateTime? insertedAt,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      userId: userId ?? this.userId,
      newSchedule: newSchedule ?? this.newSchedule,
      leaveStatus: leaveStatus ?? this.leaveStatus,
      leaveRequests: leaveRequests ?? this.leaveRequests,
      insertedAt: insertedAt ?? this.insertedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
