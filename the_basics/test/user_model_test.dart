import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_basics/features/auth/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    final now = DateTime(2024, 1, 1);

    test('toMap returns correct fields', () {
      final user = UserModel(
        id: '1',
        firstName: 'Jan',
        lastName: 'Kowalski',
        email: 'jan@test.pl',
        marketId: 'market_1',
        insertedAt: now,
        updatedAt: now,
      );

      final map = user.toMap();

      expect(map['id'], '1');
      expect(map['firstName'], 'Jan');
      expect(map['lastName'], 'Kowalski');
      expect(map['email'], 'jan@test.pl');
      expect(map['marketId'], 'market_1');
    });

    test('copyWith updates fields correctly', () {
      final user = UserModel(
        id: '1',
        firstName: 'Jan',
        lastName: 'Kowalski',
        email: 'jan@test.pl',
        marketId: 'market_1',
        insertedAt: now,
        updatedAt: now,
      );

      final updated = user.copyWith(firstName: 'Adam', maxWeeklyHours: 20);

      expect(updated.firstName, 'Adam');
      expect(updated.maxWeeklyHours, 20);
      expect(updated.lastName, 'Kowalski'); // inne pola pozostają
    });

    test('copyWithUpdatedTags replaces tag correctly', () {
      final user = UserModel(
        id: '1',
        firstName: 'Jan',
        lastName: 'Kowalski',
        email: 'jan@test.pl',
        marketId: 'market_1',
        tags: ['sprzedawca', 'księgowy'],
        insertedAt: now,
        updatedAt: now,
      );

      final updated = user.copyWithUpdatedTags('sprzedawca', 'manager');
      expect(updated.tags, ['manager', 'księgowy']);

      // Jeśli tag nie istnieje, lista pozostaje bez zmian
      final unchanged = user.copyWithUpdatedTags('brak', 'manager');
      expect(unchanged.tags, ['sprzedawca', 'księgowy']);
    });

    test('fromMap creates correct UserModel', () {
      final map = {
        'id': '1',
        'firstName': 'Jan',
        'lastName': 'Kowalski',
        'email': 'jan@test.pl',
        'marketId': 'market_1',
        'tags': ['sprzedawca'],
        'insertedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final doc = FakeDocumentSnapshot('1', map);
      final user = UserModel.fromMap(doc);

      expect(user.id, '1');
      expect(user.firstName, 'Jan');
      expect(user.tags, ['sprzedawca']);
    });

    test('fromFirestore creates correct UserModel', () {
      final map = {
        'firstName': 'Jan',
        'lastName': 'Kowalski',
        'email': 'jan@test.pl',
        'marketId': 'market_1',
        'tags': ['sprzedawca'],
        'insertedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'maxWeeklyHours': 40,
      };

      final doc = FakeDocumentSnapshot('1', map);
      final user = UserModel.fromFirestore(doc);

      expect(user.id, '1');
      expect(user.firstName, 'Jan');
      expect(user.tags, ['sprzedawca']);
      expect(user.maxWeeklyHours, 40);
    });

    test('fromFirestore returns empty UserModel if doc does not exist', () {
      final doc = FakeDocumentSnapshot.nonExistent();
      final user = UserModel.fromFirestore(doc);

      expect(user.id, '');
      expect(user.firstName, '');
      expect(user.tags, []);
    });

    test('empty returns UserModel with default values', () {
      final user = UserModel.empty();

      expect(user.id, '');
      expect(user.role, 'employee');
      expect(user.isDeleted, false);
      expect(user.numberOfLeaves, 0);
      expect(user.hasLoggedIn, false);
      expect(user.scheduleNotifs, true);
      expect(user.leaveNotifs, true);
      expect(user.gender, 'Nie określono');
    });
  });
}

/// Fake DocumentSnapshot do testowania fromMap / fromFirestore
class FakeDocumentSnapshot extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic>? _data;
  final bool _exists;

  FakeDocumentSnapshot(this._id, this._data) : _exists = true;

  FakeDocumentSnapshot.nonExistent()
      : _id = '',
        _data = null,
        _exists = false;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => _exists;

  @override
  String get id => _id;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
