import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_basics/features/tags/models/tags_model.dart';
import 'package:the_basics/data/repositiories/other/tags_repo.dart';
import 'package:the_basics/data/repositiories/exceptions.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late TagsRepo repo;
  late MockFirebaseFirestore firestore;
  late MockCollectionReference marketCollection;
  late MockCollectionReference tagsCollection;
  late MockDocumentReference docRef;
  late MockQuery query;
  late MockQuerySnapshot querySnapshot;
  late MockQueryDocumentSnapshot queryDocSnap;

  final tag = TagsModel(
    id: 'tag_1',
    tagName: 'Promo',
    description: 'Promocja',
    marketId: 'market_1',
    insertedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    firestore = MockFirebaseFirestore();
    marketCollection = MockCollectionReference();
    tagsCollection = MockCollectionReference();
    docRef = MockDocumentReference();
    query = MockQuery();
    querySnapshot = MockQuerySnapshot();
    queryDocSnap = MockQueryDocumentSnapshot();

    repo = TagsRepo(firestore: firestore);
  });

  group('saveTag', () {
    test('saves tag successfully', () async {
      when(() => firestore.collection('Markets')).thenReturn(marketCollection);
      when(() => marketCollection.doc(tag.marketId)).thenReturn(docRef);
      when(() => docRef.collection('Tags')).thenReturn(tagsCollection);
      when(() => tagsCollection.doc(tag.id)).thenReturn(docRef);
      when(() => docRef.set(any())).thenAnswer((_) async {});

      await repo.saveTag(tag);

      verify(() => docRef.set(tag.toMap())).called(1);
    });

    test('throws String on FirebaseException', () async {
      when(() => firestore.collection('Markets'))
          .thenThrow(FirebaseException(plugin: 'firestore', code: 'err'));

      expect(() => repo.saveTag(tag), throwsA(isA<String>()));
    });

    test('throws MyFormatException on FormatException', () async {
      when(() => firestore.collection('Markets')).thenReturn(marketCollection);
      when(() => marketCollection.doc(tag.marketId)).thenReturn(docRef);
      when(() => docRef.collection('Tags')).thenReturn(tagsCollection);
      when(() => tagsCollection.doc(tag.id)).thenReturn(docRef);
      when(() => docRef.set(any())).thenThrow(FormatException());

      expect(() => repo.saveTag(tag), throwsA(isA<MyFormatException>()));
    });
  });

  group('getAllTags', () {
    test('returns list of tags', () async {
      when(() => firestore.collection('Markets')).thenReturn(marketCollection);
      when(() => marketCollection.doc(tag.marketId)).thenReturn(docRef);
      when(() => docRef.collection('Tags')).thenReturn(tagsCollection);
      when(() => tagsCollection.where('isDeleted', isEqualTo: false))
          .thenReturn(query);
      when(() => query.get()).thenAnswer((_) async => querySnapshot);
      when(() => querySnapshot.docs).thenReturn([queryDocSnap]);
      when(() => queryDocSnap.data()).thenReturn(tag.toMap());

      final result = await repo.getAllTags(tag.marketId);

      expect(result.length, 1);
      expect(result.first.id, tag.id);
    });

    test('returns empty list if no docs', () async {
      when(() => firestore.collection('Markets')).thenReturn(marketCollection);
      when(() => marketCollection.doc(tag.marketId)).thenReturn(docRef);
      when(() => docRef.collection('Tags')).thenReturn(tagsCollection);
      when(() => tagsCollection.where('isDeleted', isEqualTo: false))
          .thenReturn(query);
      when(() => query.get()).thenAnswer((_) async => querySnapshot);
      when(() => querySnapshot.docs).thenReturn([]);

      final result = await repo.getAllTags(tag.marketId);

      expect(result, isEmpty);
    });
  });

  group('getTagById', () {
    test('returns tag if exists', () async {
      final docSnap = MockDocumentSnapshot();
      when(() => firestore.collection('Tags')).thenReturn(tagsCollection);
      when(() => tagsCollection.doc(tag.id)).thenReturn(docRef);
      when(() => docRef.get()).thenAnswer((_) async => docSnap);
      when(() => docSnap.exists).thenReturn(true);
      when(() => docSnap.data()).thenReturn(tag.toMap());

      final result = await repo.getTagById(tag.id);

      expect(result!.id, tag.id);
    });

    test('returns null if tag does not exist', () async {
      final docSnap = MockDocumentSnapshot();
      when(() => firestore.collection('Tags')).thenReturn(tagsCollection);
      when(() => tagsCollection.doc(tag.id)).thenReturn(docRef);
      when(() => docRef.get()).thenAnswer((_) async => docSnap);
      when(() => docSnap.exists).thenReturn(false);

      final result = await repo.getTagById(tag.id);

      expect(result, isNull);
    });
  });

  group('updateTag', () {
    test('updates tag successfully', () async {
      when(() => firestore.collection('Tags')).thenReturn(tagsCollection);
      when(() => tagsCollection.doc(tag.id)).thenReturn(docRef);
      when(() => docRef.update(any())).thenAnswer((_) async {});

      await repo.updateTag(tag);

      verify(() => docRef.update(tag.toMap())).called(1);
    });
  });

  group('deleteTag', () {
    test('deletes tag successfully', () async {
      when(() => firestore.collection('Tags')).thenReturn(tagsCollection);
      when(() => tagsCollection.doc(tag.id)).thenReturn(docRef);
      when(() => docRef.delete()).thenAnswer((_) async {});

      await repo.deleteTag(tag.id);

      verify(() => docRef.delete()).called(1);
    });
  });
}
