import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:the_basics/features/templates/models/template_model.dart';
import 'package:the_basics/features/templates/models/template_shift_model.dart';

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late DateTime insertedAt;
  late DateTime updatedAt;
  late TemplateModel template;

  setUp(() {
    insertedAt = DateTime.utc(2024, 1, 1, 10);
    updatedAt = DateTime.utc(2024, 1, 2, 12);

    template = TemplateModel(
      id: 'template1',
      templateName: 'Morning template',
      description: 'Description',
      marketId: 'market1',
      minWomen: 1,
      maxWomen: 3,
      minMen: 2,
      maxMen: 4,
      isDataMissing: false,
      isDeleted: false,
      insertedAt: insertedAt,
      updatedAt: updatedAt,
    );
  });

  group('empty', () {
    test('returns empty TemplateModel', () {
      final empty = TemplateModel.empty();

      expect(empty.id, '');
      expect(empty.templateName, '');
      expect(empty.description, '');
      expect(empty.marketId, '');
      expect(empty.isDeleted, false);
      expect(empty.isDataMissing, false);
      expect(empty.insertedAt.isBefore(DateTime.now()), true);
      expect(empty.updatedAt.isBefore(DateTime.now()), true);
    });
  });

  group('toMap', () {
    test('converts TemplateModel to correct map', () {
      final map = template.toMap();

      expect(map['id'], 'template1');
      expect(map['templateName'], 'Morning template');
      expect(map['description'], 'Description');
      expect(map['marketId'], 'market1');
      expect(map['minWomen'], 1);
      expect(map['maxWomen'], 3);
      expect(map['minMen'], 2);
      expect(map['maxMen'], 4);
      expect(map['isDataMissing'], false);
      expect(map['isDeleted'], false);
      expect(map['insertedAt'], insertedAt.toIso8601String());
      expect(map['updatedAt'], updatedAt.toIso8601String());
      expect(map['deletedAt'], null);
    });
  });

  group('fromSnapshot', () {
    test('creates TemplateModel from Firestore snapshot', () {
      final doc = MockDocumentSnapshot();

      when(() => doc.id).thenReturn('docId');
      when(() => doc.data()).thenReturn({
        'id': 'templateX',
        'templateName': 'Evening template',
        'description': 'Desc',
        'marketId': 'marketX',
        'minWomen': 2,
        'maxWomen': 5,
        'minMen': 1,
        'maxMen': 6,
        'isDataMissing': true,
        'isDeleted': false,
        'insertedAt': insertedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      });

      final result = TemplateModel.fromSnapshot(doc);

      expect(result.id, 'templateX');
      expect(result.templateName, 'Evening template');
      expect(result.description, 'Desc');
      expect(result.marketId, 'marketX');
      expect(result.minWomen, 2);
      expect(result.maxWomen, 5);
      expect(result.minMen, 1);
      expect(result.maxMen, 6);
      expect(result.isDataMissing, true);
      expect(result.isDeleted, false);
      expect(result.insertedAt, insertedAt);
      expect(result.updatedAt, updatedAt);
      expect(result.deletedAt, null);
    });

    test('uses defaults when snapshot data is null', () {
      final doc = MockDocumentSnapshot();

      when(() => doc.data()).thenReturn(null);

      final result = TemplateModel.fromSnapshot(doc);

      expect(result.id, '');
      expect(result.templateName, '');
      expect(result.description, '');
      expect(result.marketId, '');
      expect(result.isDeleted, false);
      expect(result.isDataMissing, false);
    });

    test('uses defaults when optional fields are missing', () {
      final doc = MockDocumentSnapshot();

      when(() => doc.id).thenReturn('fallbackId');
      when(() => doc.data()).thenReturn({
        'insertedAt': insertedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      });

      final result = TemplateModel.fromSnapshot(doc);

      expect(result.id, 'fallbackId');
      expect(result.templateName, '');
      expect(result.description, '');
      expect(result.marketId, '');
      expect(result.minWomen, null);
      expect(result.maxWomen, null);
      expect(result.isDataMissing, false);
      expect(result.isDeleted, false);
    });
  });

  group('copyWith', () {
    test('creates copy with updated fields', () {
      final copied = template.copyWith(
        templateName: 'Updated name',
        minWomen: 5,
        isDeleted: true,
      );

      expect(copied.id, template.id);
      expect(copied.templateName, 'Updated name');
      expect(copied.minWomen, 5);
      expect(copied.isDeleted, true);
      expect(copied.marketId, template.marketId);
      expect(copied.insertedAt, template.insertedAt);
      expect(copied.updatedAt, template.updatedAt);
    });

    test('returns identical object when no params provided', () {
      final copied = template.copyWith();

      expect(copied.id, template.id);
      expect(copied.templateName, template.templateName);
      expect(copied.description, template.description);
      expect(copied.marketId, template.marketId);
      expect(copied.minWomen, template.minWomen);
      expect(copied.maxWomen, template.maxWomen);
      expect(copied.minMen, template.minMen);
      expect(copied.maxMen, template.maxMen);
      expect(copied.isDeleted, template.isDeleted);
      expect(copied.isDataMissing, template.isDataMissing);
      expect(copied.insertedAt, template.insertedAt);
      expect(copied.updatedAt, template.updatedAt);
      expect(copied.deletedAt, template.deletedAt);
      expect(copied.shifts, template.shifts);
    });
  });
}
