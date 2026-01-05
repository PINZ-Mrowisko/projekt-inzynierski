import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/tags/models/tags_model.dart';
import '../exceptions.dart';

class TagsRepo extends GetxController {
  static TagsRepo get instance => Get.find();

  final FirebaseFirestore _db;

  // Konstruktor z możliwością wstrzykiwania mocka Firestore
  TagsRepo({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  Future<void> saveTag(TagsModel tag) async {
    try {
      await _db
          .collection("Markets")
          .doc(tag.marketId)
          .collection("Tags")
          .doc(tag.id)
          .set(tag.toMap());
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Coś poszło nie tak :(';
    }
  }

  Future<List<TagsModel>> getAllTags(String marketId) async {
    try {
      final snapshot = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Tags')
          .where('isDeleted', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((e) => TagsModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Coś poszło nie tak :(';
    }
  }

  Future<TagsModel?> getTagById(String tagId) async {
    try {
      final doc = await _db.collection('Tags').doc(tagId).get();
      if (doc.exists) return TagsModel.fromSnapshot(doc);
      return null;
    } catch (e) {
      throw 'Nie udało się pobrać tagu: ${e.toString()}';
    }
  }

  Future<void> updateTag(TagsModel tag) async {
    try {
      await _db.collection('Tags').doc(tag.id).update(tag.toMap());
    } catch (e) {
      throw 'Nie udało się zaktualizować tagu: ${e.toString()}';
    }
  }

  /// Usuwa tag o konkretnym id
  /// TO DO : dodać sprawdzenia, czy jacys pracownicy posiadaja dany tag
  ///
  /// tak w sumie stwierdzilam ze tagow nie ma sensu trzymac w celach historycznych
  /// wiec nie ma co ich oznaczac isDeleted czy cos
  /// TO DO:
  /// usunac isDeleted i deletedAt z modelu tagow

  Future<void> deleteTag(String tagId) async {
    try {
      await _db.collection('Tags').doc(tagId).delete();
    } catch (e) {
      throw 'Nie udało się usunąć tagu: ${e.toString()}';
    }
  }
}
