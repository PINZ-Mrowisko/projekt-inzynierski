import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModel {
  final String id; // id wniosku
  final String userId; // employeeRequesting
  final String name; // name of the emp requesting
  final String marketId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  // final String leaveType;
  final String? comment;
  final String status ;
  final String? managerId;
  final bool isDeleted;
  final DateTime insertedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  LeaveModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.marketId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    //required this.leaveType,
    this.status = "Oczekujący",
    this.comment,
    this.managerId,
    this.isDeleted = false,
    required this.insertedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  static LeaveModel empty() => LeaveModel(
    id: '',
    userId: '',
    name: '',
    marketId: '',
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    totalDays: 0,
    //leaveType: 'Urlop na żądanie',
    comment: '',
    status: 'Oczekujący',
    insertedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'marketId': marketId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      //'leaveType': leaveType,
      'comment': comment,
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
      name: map['name'] ?? '',
      marketId: map['marketId'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      totalDays: map['totalDays'] ?? 0,
      //leaveType: map['leaveType'] ?? 'Urlop wypoczynkowy',
      comment: map['comment'] ?? '',
      status: map['status'] ?? 'Oczekujący',
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
    String? name,
    String? marketId,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    //String? leaveType,
    String? comment,
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
      name: name ?? this.name,
      marketId: marketId ?? this.marketId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      //leaveType: leaveType ?? this.leaveType,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      managerId: managerId ?? this.managerId,
      isDeleted: isDeleted ?? this.isDeleted,
      insertedAt: insertedAt ?? this.insertedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
