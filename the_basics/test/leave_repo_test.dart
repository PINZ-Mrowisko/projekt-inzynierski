// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
//
// import 'package:the_basics/features/leaves/models/leave_model.dart';
// import 'package:the_basics/data/repositiories/exceptions.dart';
//
// class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
// class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
// class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
// class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
// class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
// class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
//
// void main() {
//   late LeaveRepo repo;
//   late MockFirebaseFirestore firestore;
//   late MockCollectionReference collection;
//   late MockDocumentReference doc;
//   late MockQuery query;
//   late MockQuery queryFiltered;
//   late MockQuerySnapshot querySnapshot;
//
//   final leave = LeaveModel(
//     id: 'leave_1',
//     userId: 'user_1',
//     name: 'Jan',
//     marketId: 'market_1',
//     startDate: DateTime(2024, 1, 1),
//     endDate: DateTime(2024, 1, 5),
//     totalDays: 4,
//     insertedAt: DateTime(2024, 1, 1),
//     updatedAt: DateTime(2024, 1, 2),
//   );
//
//   setUp(() {
//     firestore = MockFirebaseFirestore();
//     collection = MockCollectionReference();
//     doc = MockDocumentReference();
//     query = MockQuery();
//     queryFiltered = MockQuery();
//     querySnapshot = MockQuerySnapshot();
//
//     repo = LeaveRepo(firestore: firestore);
//   });
//
//   group('saveLeave', () {
//     test('saves leave successfully', () async {
//       when(() => firestore.collection('Markets')).thenReturn(collection);
//       when(() => collection.doc(leave.marketId)).thenReturn(doc);
//       when(() => doc.collection('LeaveReq')).thenReturn(collection);
//       when(() => collection.doc(leave.id)).thenReturn(doc);
//       when(() => doc.set(any())).thenAnswer((_) async {});
//
//       await repo.saveLeave(leave);
//
//       verify(() => doc.set(leave.toMap())).called(1);
//     });
//
//     test('throws String on FirebaseException', () async {
//       when(() => firestore.collection('Markets')).thenThrow(FirebaseException(plugin: 'firestore', code: 'err'));
//
//       expect(() => repo.saveLeave(leave), throwsA(isA<String>()));
//     });
//
//     test('throws MyFormatException', () async {
//       when(() => firestore.collection('Markets')).thenThrow(FormatException());
//
//       expect(() => repo.saveLeave(leave), throwsA(isA<MyFormatException>()));
//     });
//
//     test('throws MyPlatformException', () async {
//       when(() => firestore.collection('Markets')).thenThrow(PlatformException(code: 'code'));
//
//       expect(() => repo.saveLeave(leave), throwsA(isA<String>()));
//     });
//   });
//
//   group('getAllLeaveRequests', () {
//     test('returns list of LeaveModel', () async {
//       final docSnap = MockQueryDocumentSnapshot();
//       when(() => docSnap.data()).thenReturn(leave.toMap());
//
//       when(() => firestore.collection('Markets')).thenReturn(collection);
//       when(() => collection.doc(leave.marketId)).thenReturn(doc);
//       when(() => doc.collection('LeaveReq')).thenReturn(collection);
//       when(() => collection.where('isDeleted', isEqualTo: false)).thenReturn(query);
//       when(() => query.get()).thenAnswer((_) async => querySnapshot);
//       when(() => querySnapshot.docs).thenReturn([docSnap]);
//
//       final result = await repo.getAllLeaveRequests(leave.marketId);
//
//       expect(result.length, 1);
//       expect(result.first.id, leave.id);
//     });
//
//     test('returns empty list when no docs', () async {
//       when(() => firestore.collection('Markets')).thenReturn(collection);
//       when(() => collection.doc(leave.marketId)).thenReturn(doc);
//       when(() => doc.collection('LeaveReq')).thenReturn(collection);
//       when(() => collection.where('isDeleted', isEqualTo: false)).thenReturn(query);
//       when(() => query.get()).thenAnswer((_) async => querySnapshot);
//       when(() => querySnapshot.docs).thenReturn([]);
//
//       final result = await repo.getAllLeaveRequests(leave.marketId);
//
//       expect(result, isEmpty);
//     });
//
//     test('throws FirebaseException', () async {
//       when(() => firestore.collection('Markets')).thenThrow(FirebaseException(plugin: 'firestore', code: 'code'));
//
//       expect(() => repo.getAllLeaveRequests(leave.marketId), throwsA(isA<String>()));
//     });
//   });
//
//   group('getRecentLeaveRequests', () {
//     test('returns recent leave requests', () async {
//       final docSnap = MockQueryDocumentSnapshot();
//       when(() => docSnap.data()).thenReturn(leave.toMap());
//
//       when(() => firestore.collection('Markets')).thenReturn(collection);
//       when(() => collection.doc(leave.marketId)).thenReturn(doc);
//       when(() => doc.collection('LeaveReq')).thenReturn(collection);
//
//       when(() => collection.where('isDeleted', isEqualTo: false)).thenReturn(query);
//       when(() => query.where('endDate', isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo'))).thenReturn(queryFiltered);
//       when(() => queryFiltered.get()).thenAnswer((_) async => querySnapshot);
//       when(() => querySnapshot.docs).thenReturn([docSnap]);
//
//       final result = await repo.getRecentLeaveRequests(leave.marketId);
//
//       expect(result, isNotEmpty);
//       expect(result.first.id, leave.id);
//     });
//
//     test('returns empty when no recent requests', () async {
//       when(() => firestore.collection('Markets')).thenReturn(collection);
//       when(() => collection.doc(leave.marketId)).thenReturn(doc);
//       when(() => doc.collection('LeaveReq')).thenReturn(collection);
//       when(() => collection.where('isDeleted', isEqualTo: false)).thenReturn(query);
//       when(() => query.where('endDate', isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo'))).thenReturn(queryFiltered);
//       when(() => queryFiltered.get()).thenAnswer((_) async => querySnapshot);
//       when(() => querySnapshot.docs).thenReturn([]);
//
//       final result = await repo.getRecentLeaveRequests(leave.marketId);
//
//       expect(result, isEmpty);
//     });
//
//     test('throws FirebaseException', () async {
//       when(() => firestore.collection('Markets')).thenThrow(FirebaseException(plugin: 'firestore', code: 'code'));
//
//       expect(() => repo.getRecentLeaveRequests(leave.marketId), throwsA(isA<String>()));
//     });
//   });
//
//   group('updateLeave', () {
//     test('updates leave successfully', () async {
//       when(() => firestore.collection('Markets')).thenReturn(collection);
//       when(() => collection.doc(leave.marketId)).thenReturn(doc);
//       when(() => doc.collection('LeaveReq')).thenReturn(collection);
//       when(() => collection.doc(leave.id)).thenReturn(doc);
//       when(() => doc.update(any())).thenAnswer((_) async {});
//
//       await repo.updateLeave(leave);
//
//       verify(() => doc.update(leave.toMap())).called(1);
//     });
//
//     test('throws on error', () async {
//       when(() => firestore.collection('Markets')).thenThrow(Exception('err'));
//
//       expect(() => repo.updateLeave(leave), throwsA(isA<String>()));
//     });
//   });
//
//   group('deleteLeave', () {
//     test('soft deletes leave', () async {
//       when(() => firestore.collection('Markets')).thenReturn(collection);
//       when(() => collection.doc(leave.marketId)).thenReturn(doc);
//       when(() => doc.collection('LeaveReq')).thenReturn(collection);
//       when(() => collection.doc(leave.id)).thenReturn(doc);
//       when(() => doc.update(any())).thenAnswer((_) async {});
//
//       await repo.deleteLeave(leave.marketId, leave.id);
//
//       verify(() => doc.update(any())).called(1);
//     });
//
//     test('throws on error', () async {
//       when(() => firestore.collection('Markets')).thenThrow(Exception('err'));
//
//       expect(() => repo.deleteLeave(leave.marketId, leave.id), throwsA(isA<String>()));
//     });
//   });
// }
