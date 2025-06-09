import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/tags/models/tags_model.dart';
import '../exceptions.dart';

class TagsRepo extends GetxController {
  static TagsRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveTag(TagsModel tag) async {
    try {
      //await _db.collection("Tags").doc(tag.id).set(tag.toMap());
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

  /// get all available tags specific to the market
  Future<List<TagsModel>> getAllTags(String marketId) async {
    try{
      // final snapshot = await _db.collection('Tags')
      //     .where('marketId', isEqualTo: marketId)
      //     .where('isDeleted', isEqualTo: false)
      //     .get();

      final snapshot = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Tags')
          .where('isDeleted', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        //print('No tags found for marketId: $marketId');
        return [];
      }

        // go through each of the tag docs and format them using our method
        final list = snapshot.docs.map((e) => TagsModel.fromSnapshot(e)).toList();
        return list;
    }on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    }catch (e) {
      throw 'Coś poszło nie tak :(';
    }
  }

  /// pobiera konkretny tag po ID i zwraca juz go w ladnie sformatowanej formie - NOT USED
  Future<TagsModel?> getTagById(String tagId) async {
    try {
      final doc = await _db.collection('Tags').doc(tagId).get();
      if (doc.exists) {
        return TagsModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw 'Nie udało się pobrać tagu: ${e.toString()}';
    }
  }

  /// Aktualizuje tag o konkretnym id - NOT USED
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