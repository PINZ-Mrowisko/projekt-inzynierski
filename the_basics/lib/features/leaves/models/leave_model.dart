import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModel {
  final String id;
  final String userId; // employeeRequesting
  final String marketId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String leaveType;
  final String status;
  final String? managerId;
  final bool isDeleted;
  final DateTime insertedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  LeaveModel({
    required this.id,
    required this.userId,
    required this.marketId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.leaveType,
    required this.status,
    this.managerId,
    this.isDeleted = false,
    required this.insertedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  static LeaveModel empty() => LeaveModel(
    id: '',
    userId: '',
    marketId: '',
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    totalDays: 0,
    leaveType: 'wypoczynkowy',
    status: 'do rozpatrzenia',
    insertedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'marketId': marketId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'leaveType': leaveType,
      'status': status,
      'managerId': managerId,
      'isDeleted': isDeleted,
      'insertedAt': insertedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory LeaveModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return LeaveModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      marketId: map['marketId'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      totalDays: map['totalDays'] ?? 0,
      leaveType: map['leaveType'] ?? 'wypoczynkowy',
      status: map['status'] ?? 'do rozpatrzenia',
      managerId: map['managerId'],
      isDeleted: map['isDeleted'] ?? false,
      insertedAt: DateTime.parse(map['insertedAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
    );
  }

  LeaveModel copyWith({
    String? id,
    String? userId,
    String? marketId,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    String? leaveType,
    String? status,
    String? managerId,
    bool? isDeleted,
    DateTime? insertedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      marketId: marketId ?? this.marketId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      leaveType: leaveType ?? this.leaveType,
      status: status ?? this.status,
      managerId: managerId ?? this.managerId,
      isDeleted: isDeleted ?? this.isDeleted,
      insertedAt: insertedAt ?? this.insertedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
