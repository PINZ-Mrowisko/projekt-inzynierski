import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShiftModel {
  final String id;
  final String day;
  final TimeOfDay start;
  final TimeOfDay end;
  final List<String> tagIds;
  final List<String> tagNames;
  final int count;

  ShiftModel({
    required this.id,
    required this.day,
    required this.start,
    required this.end,
    required this.tagIds,
    required this.tagNames,
    required this.count,
  });

  /// Converts to a map suitable for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      // store times as strings
      'start': '${start.hour}:${start.minute}',
      'end': '${end.hour}:${end.minute}',
      'tagIds': tagIds,
      'tagNames': tagNames,
      'count': count,
    };
  }

  /// Recreates a ShiftModel from Firestore data
  factory ShiftModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ShiftModel(
      id: data['id'] ?? doc.id,
      day: data['day'] ?? '',
      start: _parseTime(data['start']),
      end: _parseTime(data['end']),
      tagIds: List<String>.from(data['tagIds'] ?? []),
      tagNames: List<String>.from(data['tagNames'] ?? []),
      count: data['count'] ?? 0,
    );
  }

  /// Helper to convert "HH:mm" string into TimeOfDay
  static TimeOfDay _parseTime(dynamic value) {
    if (value is String && value.contains(':')) {
      final parts = value.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  ShiftModel copyWith({
    String? day,
    List<String>? tagIds, // ZMIANA
    List<String>? tagNames, // ZMIANA
    int? count,
    TimeOfDay? start,
    TimeOfDay? end
  }) {
    return ShiftModel(
        day: day ?? this.day,
        start: start ?? this.start,
        end: end ?? this.end,
        tagIds: tagIds ?? this.tagIds,
        tagNames: tagNames ?? this.tagNames,
        count: count ?? this.count,
        id: id
    );
  }
}