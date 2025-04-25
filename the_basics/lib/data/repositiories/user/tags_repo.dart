import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/schedules/controllers/user_controller.dart';
import '../../../features/schedules/models/tags_model.dart';
import '../exceptions.dart';

class TagsRepo extends GetxController {
  static TagsRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveTag(TagsModel tag) async {
    try {
      await _db.collection("Tags").doc(tag.id).set(tag.toMap());
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
      final snapshot = await _db.collection('Tags')
          .where('marketId', isEqualTo: marketId)
          .where('isDeleted', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No tags found for marketId: $marketId');
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
}