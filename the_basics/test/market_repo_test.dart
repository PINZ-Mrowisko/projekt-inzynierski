// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:the_basics/data/repositiories/other/markets/market_repo.dart';
// import 'package:the_basics/features/auth/models/user_model.dart';
// import 'package:the_basics/features/auth/models/market_model.dart';
// import 'package:the_basics/data/repositiories/exceptions.dart';
//
// class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
// class MockCollectionReference extends Mock
//     implements CollectionReference<Map<String, dynamic>> {}
// class MockDocumentReference extends Mock
//     implements DocumentReference<Map<String, dynamic>> {}
//
// void main() {
//   late MarketRepo repo;
//   late MockFirebaseFirestore firestore;
//   late MockCollectionReference collection;
//   late MockDocumentReference doc;
//
//   final market = MarketModel(
//     id: 'market_1',
//     marketName: 'SuperMarket',
//     createdBy: 'user_1',
//     insertedAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//   );
//
//   final user = UserModel(
//     id: 'user_1',
//     firstName: 'Jan',
//     lastName: 'Kowalski',
//     email: 'jan@test.pl',
//     marketId: market.id,
//     insertedAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//   );
//
//   setUp(() {
//     firestore = MockFirebaseFirestore();
//     collection = MockCollectionReference();
//     doc = MockDocumentReference();
//     repo = MarketRepo(firestore: firestore);
//   });
//
//   group('saveMarket', () {
//     test('saves market and first user successfully', () async {
//       // Stub main collection for market
//       when(() => firestore.collection('Markets')).thenReturn(collection);
//       when(() => collection.doc(market.id)).thenReturn(doc);
//       when(() => doc.set(any())).thenAnswer((_) async {});
//
//       // Stub members subcollection
//       final membersCollection = MockCollectionReference();
//       final memberDoc = MockDocumentReference();
//
//       when(() => doc.collection('members')).thenReturn(membersCollection);
//       when(() => membersCollection.doc(user.id)).thenReturn(memberDoc);
//       when(() => memberDoc.set(any())).thenAnswer((_) async {});
//
//       // Inject mocked firestore into repo using optional constructor
//       await repo.saveMarket(market, user, user.id);
//
//       verify(() => doc.set(market.toMap())).called(1);
//       verify(() => memberDoc.set(user.toMap())).called(1);
//     });
//
//     test('throws String on FirebaseException', () async {
//       when(() => firestore.collection('Markets'))
//           .thenThrow(FirebaseException(plugin: 'firestore', code: 'err'));
//
//       expect(
//         () => repo.saveMarket(market, user, user.id),
//         throwsA(isA<String>()),
//       );
//     });
//
//     test('throws MyFormatException on FormatException', () async {
//       // We force a FormatException by mocking set to throw FormatException
//       when(() => firestore.collection('Markets')).thenReturn(collection);
//       when(() => collection.doc(market.id)).thenReturn(doc);
//       when(() => doc.set(any())).thenThrow(FormatException());
//
//       expect(
//         () => repo.saveMarket(market, user, user.id),
//         throwsA(isA<MyFormatException>()),
//       );
//     });
//
//     test('throws String on any other exception', () async {
//       when(() => firestore.collection('Markets')).thenReturn(collection);
//       when(() => collection.doc(market.id)).thenReturn(doc);
//       when(() => doc.set(any())).thenThrow(Exception('unknown'));
//
//       expect(
//         () => repo.saveMarket(market, user, user.id),
//         throwsA(isA<String>()),
//       );
//     });
//   });
// }
