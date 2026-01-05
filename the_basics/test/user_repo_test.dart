import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_basics/data/repositiories/user/user_repo.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/data/repositiories/exceptions.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late UserRepo userRepo;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockDocSnapshot;
  late MockQuerySnapshot mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();
    mockQuerySnapshot = MockQuerySnapshot();

    userRepo = UserRepo(firestore: mockFirestore);
  });

  final user = UserModel(
    id: '1',
    firstName: 'Jan',
    lastName: 'Kowalski',
    email: 'jan@test.pl',
    marketId: 'market_1',
    insertedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('saveUser', () {
    test('saves user successfully', () async {
      when(() => mockFirestore.collection('Users')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.set(any())).thenAnswer((_) async => Future.value());

      await userRepo.saveUser(user);

      verify(() => mockDocRef.set(user.toMap())).called(1);
    });

    test('throws MyFirebaseException on FirebaseException', () async {
      when(() => mockFirestore.collection('Users')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.set(any())).thenThrow(FirebaseException(plugin: 'firestore', code: 'code'));

      expect(() => userRepo.saveUser(user), throwsA(isA<String>()));
    });
  });

  group('getAllEmployees', () {
    test('returns list of UserModel', () async {
      final mockQueryDoc = MockQueryDocumentSnapshot();
      when(() => mockQueryDoc.data()).thenReturn(user.toMap());

      when(() => mockFirestore.collection('Markets')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.marketId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('members')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.where('isDeleted', isEqualTo: false)).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);

      final result = await userRepo.getAllEmployees(user.marketId);

      expect(result.length, 1);
      expect(result.first.id, user.id);
    });

    test('returns empty list if no docs', () async {
      when(() => mockFirestore.collection('Markets')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.marketId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('members')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.where('isDeleted', isEqualTo: false)).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      final result = await userRepo.getAllEmployees(user.marketId);

      expect(result, isEmpty);
    });

    test('throws MyFirebaseException on FirebaseException', () async {
      when(() => mockFirestore.collection('Markets')).thenThrow(FirebaseException(plugin: 'firestore', code: 'code'));

      expect(() => userRepo.getAllEmployees(user.marketId), throwsA(isA<String>()));
    });
  });

  group('addNewEmployee', () {
    test('adds employee successfully', () async {
      when(() => mockFirestore.collection('Users')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.set(any())).thenAnswer((_) async => Future.value());

      when(() => mockFirestore.collection('Markets')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.marketId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('members')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.set(any())).thenAnswer((_) async => Future.value());

      await userRepo.addNewEmployee(user, user);

      verify(() => mockDocRef.set(user.toMap())).called(greaterThan(0));
    });

    test('throws on FirebaseException', () async {
      when(() => mockFirestore.collection('Users')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.set(any())).thenThrow(FirebaseException(plugin: 'firestore', code: 'code'));

      expect(() => userRepo.addNewEmployee(user, user), throwsA(isA<String>()));
    });
  });

  group('updateUserDetails', () {
    test('updates user successfully', () async {
      when(() => mockFirestore.collection('Markets')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.marketId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('members')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.update(user.toMap())).thenAnswer((_) async => Future.value());

      await userRepo.updateUserDetails(user);

      verify(() => mockDocRef.update(user.toMap())).called(1);
    });

    test('throws on FirebaseException', () async {
      when(() => mockFirestore.collection('Markets')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.marketId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('members')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.update(any())).thenThrow(FirebaseException(plugin: 'firestore', code: 'code'));

      expect(() => userRepo.updateUserDetails(user), throwsA(isA<String>()));
    });
  });

  group('removeUser', () {
    test('removes user successfully', () async {
      when(() => mockFirestore.collection('Users')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.update(any())).thenAnswer((_) async => Future.value());

      when(() => mockFirestore.collection('Markets')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.marketId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('members')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.update(any())).thenAnswer((_) async => Future.value());

      await userRepo.removeUser(user.id, user.marketId);

      verify(() => mockDocRef.update(any())).called(greaterThan(0));
    });
  });

  group('getUserDetails', () {
    test('returns user details when exists', () async {
      when(() => mockFirestore.collection('Markets')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.marketId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('members')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.data()).thenReturn(user.toMap());

      final result = await userRepo.getUserDetails(user.id, user.marketId);

      expect(result.id, user.id);
    });

    test('throws when user does not exist', () async {
      when(() => mockFirestore.collection('Markets')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.marketId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('members')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);

      expect(() => userRepo.getUserDetails(user.id, user.marketId), throwsA(isA<String>()));
    });
  });

  group('getManager', () {
    test('returns manager when exists', () async {
      final mockQueryDoc = MockQueryDocumentSnapshot();
      when(() => mockQueryDoc.data()).thenReturn(user.toMap());

      when(() => mockFirestore.collection('Markets')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.marketId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('members')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.where('role', isEqualTo: 'admin')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.limit(1)).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);

      final result = await userRepo.getManager(user.marketId);

      expect(result!.id, user.id);
    });

    test('returns null when no manager', () async {
      when(() => mockFirestore.collection('Markets')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(user.marketId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('members')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.where('role', isEqualTo: 'admin')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.limit(1)).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      final result = await userRepo.getManager(user.marketId);

      expect(result, isNull);
    });
  });
}
