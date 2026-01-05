// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'package:the_basics/features/templates/models/template_shift_model.dart';
//
// // Mock DocumentSnapshot
// class MockDocumentSnapshot extends Mock
//     implements DocumentSnapshot<Map<String, dynamic>> {}
//
// void main() {
//   late ShiftModel shift;
//
//   setUp(() {
//     shift = ShiftModel(
//       id: '1',
//       day: 'Monday',
//       start: const TimeOfDay(hour: 8, minute: 30),
//       end: const TimeOfDay(hour: 16, minute: 0),
//       tagId: 'tag1',
//       tagName: 'Morning',
//       count: 2,
//     );
//   });
//
//   group('toMap', () {
//     test('returns correct map representation', () {
//       final map = shift.toMap();
//
//       expect(map['id'], '1');
//       expect(map['day'], 'Monday');
//       expect(map['start'], '8:30');
//       expect(map['end'], '16:0');
//       expect(map['tagId'], 'tag1');
//       expect(map['tagName'], 'Morning');
//       expect(map['count'], 2);
//     });
//   });
//
//   group('fromSnapshot', () {
//     test('creates ShiftModel from valid Firestore data', () {
//       final doc = MockDocumentSnapshot();
//
//       when(() => doc.id).thenReturn('docId');
//       when(() => doc.data()).thenReturn({
//         'id': '123',
//         'day': 'Tuesday',
//         'start': '9:15',
//         'end': '17:45',
//         'tagId': 'tag2',
//         'tagName': 'Evening',
//         'count': 3,
//       });
//
//       final result = ShiftModel.fromSnapshot(doc);
//
//       expect(result.id, '123');
//       expect(result.day, 'Tuesday');
//       expect(result.start.hour, 9);
//       expect(result.start.minute, 15);
//       expect(result.end.hour, 17);
//       expect(result.end.minute, 45);
//       expect(result.tagId, 'tag2');
//       expect(result.tagName, 'Evening');
//       expect(result.count, 3);
//     });
//
//     test('uses defaults when Firestore data is missing', () {
//       final doc = MockDocumentSnapshot();
//
//       when(() => doc.id).thenReturn('fallbackId');
//       when(() => doc.data()).thenReturn({});
//
//       final result = ShiftModel.fromSnapshot(doc);
//
//       expect(result.id, 'fallbackId');
//       expect(result.day, '');
//       expect(result.start, const TimeOfDay(hour: 0, minute: 0));
//       expect(result.end, const TimeOfDay(hour: 0, minute: 0));
//       expect(result.tagId, '');
//       expect(result.tagName, '');
//       expect(result.count, 0);
//     });
//   });
//
//   group('_parseTime (indirectly via fromSnapshot)', () {
//     test('returns 00:00 for invalid time format', () {
//       final doc = MockDocumentSnapshot();
//
//       when(() => doc.id).thenReturn('id');
//       when(() => doc.data()).thenReturn({
//         'start': 'invalid',
//         'end': null,
//       });
//
//       final result = ShiftModel.fromSnapshot(doc);
//
//       expect(result.start, const TimeOfDay(hour: 0, minute: 0));
//       expect(result.end, const TimeOfDay(hour: 0, minute: 0));
//     });
//   });
//
//   group('copyWith', () {
//     test('copies with new values', () {
//       final copied = shift.copyWith(
//         day: 'Friday',
//         tagId: 'tagX',
//         tagName: 'Night',
//         count: 5,
//         start: const TimeOfDay(hour: 22, minute: 0),
//         end: const TimeOfDay(hour: 6, minute: 0),
//       );
//
//       expect(copied.id, '1');
//       expect(copied.day, 'Friday');
//       expect(copied.tagId, 'tagX');
//       expect(copied.tagName, 'Night');
//       expect(copied.count, 5);
//       expect(copied.start.hour, 22);
//       expect(copied.end.hour, 6);
//     });
//
//     test('keeps original values when copyWith params are null', () {
//       final copied = shift.copyWith();
//
//       expect(copied.day, shift.day);
//       expect(copied.start, shift.start);
//       expect(copied.end, shift.end); // błąd w modelu
//       expect(copied.tagId, shift.tagId);
//       expect(copied.tagName, shift.tagName);
//       expect(copied.count, shift.count);
//     });
//   });
// }
