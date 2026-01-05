import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:the_basics/features/leaves/models/leave_model.dart';

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late LeaveModel leave;

  setUp(() {
    leave = LeaveModel(
      id: 'leave_1',
      userId: 'user_1',
      name: 'Jan Kowalski',
      marketId: 'market_1',
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 5),
      totalDays: 4,
      comment: 'Urlop',
      status: 'Oczekujący',
      managerId: 'manager_1',
      isDeleted: false,
      insertedAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );
  });

  group('constructor & defaults', () {
    test('creates LeaveModel correctly', () {
      expect(leave.id, 'leave_1');
      expect(leave.status, 'Oczekujący');
      expect(leave.isDeleted, false);
    });

    test('empty() creates default LeaveModel', () {
      final empty = LeaveModel.empty();

      expect(empty.id, '');
      expect(empty.userId, '');
      expect(empty.totalDays, 0);
      expect(empty.status, 'Oczekujący');
      expect(empty.isDeleted, false);
    });
  });

  group('toMap', () {
    test('converts LeaveModel to map', () {
      final map = leave.toMap();

      expect(map['id'], leave.id);
      expect(map['userId'], leave.userId);
      expect(map['name'], leave.name);
      expect(map['marketId'], leave.marketId);
      expect(map['totalDays'], leave.totalDays);
      expect(map['status'], leave.status);
      expect(map['isDeleted'], leave.isDeleted);
      expect(map['deletedAt'], null);
    });

    test('includes deletedAt when present', () {
      final deletedLeave = leave.copyWith(
        isDeleted: true,
        deletedAt: DateTime(2024, 1, 10),
      );

      final map = deletedLeave.toMap();

      expect(map['isDeleted'], true);
      expect(map['deletedAt'], isNotNull);
    });
  });

  group('fromSnapshot', () {
    test('creates LeaveModel from snapshot', () {
      final snapshot = MockDocumentSnapshot();

      when(() => snapshot.data()).thenReturn({
        'id': 'leave_1',
        'userId': 'user_1',
        'name': 'Jan Kowalski',
        'marketId': 'market_1',
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-01-05T00:00:00.000',
        'totalDays': 4,
        'comment': 'Urlop',
        'status': 'Oczekujący',
        'managerId': 'manager_1',
        'isDeleted': false,
        'insertedAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      });

      final result = LeaveModel.fromSnapshot(snapshot);

      expect(result.id, 'leave_1');
      expect(result.userId, 'user_1');
      expect(result.name, 'Jan Kowalski');
      expect(result.totalDays, 4);
      expect(result.deletedAt, null);
    });

    test('parses deletedAt when present', () {
      final snapshot = MockDocumentSnapshot();

      when(() => snapshot.data()).thenReturn({
        'id': 'leave_1',
        'userId': 'user_1',
        'name': 'Jan Kowalski',
        'marketId': 'market_1',
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-01-05T00:00:00.000',
        'totalDays': 4,
        'status': 'Oczekujący',
        'isDeleted': true,
        'insertedAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
        'deletedAt': '2024-01-10T00:00:00.000',
      });

      final result = LeaveModel.fromSnapshot(snapshot);

      expect(result.isDeleted, true);
      expect(result.deletedAt, isNotNull);
    });

    test('uses default values when fields missing', () {
      final snapshot = MockDocumentSnapshot();

      when(() => snapshot.data()).thenReturn({
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-01-05T00:00:00.000',
        'insertedAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      });

      final result = LeaveModel.fromSnapshot(snapshot);

      expect(result.id, '');
      expect(result.status, 'Oczekujący');
      expect(result.totalDays, 0);
    });
  });

  group('copyWith', () {
    test('copies with new values', () {
      final updated = leave.copyWith(
        status: 'Zaakceptowany',
        isDeleted: true,
      );

      expect(updated.status, 'Zaakceptowany');
      expect(updated.isDeleted, true);
      expect(updated.id, leave.id);
    });

    test('returns identical object when no params passed', () {
      final copied = leave.copyWith();

      expect(copied.id, leave.id);
      expect(copied.status, leave.status);
      expect(copied.updatedAt, leave.updatedAt);
    });
  });
}
