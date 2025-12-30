import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_basics/features/tags/models/tags_model.dart';

// Mock Firestore DocumentSnapshot
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late TagsModel tag;
  late DateTime now;

  setUp(() {
    now = DateTime.now();
    tag = TagsModel(
      id: '1',
      tagName: 'Tag1',
      description: 'Description1',
      marketId: 'market_1',
      insertedAt: now,
      updatedAt: now,
    );
  });

  group('TagsModel', () {
    test('toMap returns correct map', () {
      final map = tag.toMap();
      expect(map['id'], '1');
      expect(map['tagName'], 'Tag1');
      expect(map['description'], 'Description1');
      expect(map['marketId'], 'market_1');
      expect(map['isDeleted'], false);
      expect(map['insertedAt'], now.toIso8601String());
      expect(map['updatedAt'], now.toIso8601String());
      expect(map['deletedAt'], null);
    });

    test('fromSnapshot returns TagsModel from data', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.data()).thenReturn({
        'id': '1',
        'tagName': 'Tag1',
        'description': 'Description1',
        'marketId': 'market_1',
        'isDeleted': true,
        'insertedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'deletedAt': now.toIso8601String(),
      });

      final model = TagsModel.fromSnapshot(mockDoc);
      expect(model.id, '1');
      expect(model.tagName, 'Tag1');
      expect(model.description, 'Description1');
      expect(model.marketId, 'market_1');
      expect(model.isDeleted, true);
      expect(model.insertedAt, now);
      expect(model.updatedAt, now);
      expect(model.deletedAt, now);
    });

    test('fromSnapshot returns empty when data is null', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.data()).thenReturn(null);

      final model = TagsModel.fromSnapshot(mockDoc);
      expect(model.id, '');
      expect(model.tagName, '');
      expect(model.description, '');
      expect(model.marketId, '');
    });

    test('copyWith creates a new instance with overridden fields', () {
      final newDate = now.add(Duration(days: 1));
      final copied = tag.copyWith(
        id: '2',
        tagName: 'Tag2',
        description: 'Desc2',
        marketId: 'market_2',
        isDeleted: true,
        insertedAt: newDate,
        updatedAt: newDate,
        deletedAt: newDate,
      );

      expect(copied.id, '2');
      expect(copied.tagName, 'Tag2');
      expect(copied.description, 'Desc2');
      expect(copied.marketId, 'market_2');
      expect(copied.isDeleted, true);
      expect(copied.insertedAt, newDate);
      expect(copied.updatedAt, newDate);
      expect(copied.deletedAt, newDate);
    });

    test('empty returns a TagsModel with default values', () {
      final emptyTag = TagsModel.empty();
      expect(emptyTag.id, '');
      expect(emptyTag.tagName, '');
      expect(emptyTag.description, '');
      expect(emptyTag.marketId, '');
    });
  });
}
