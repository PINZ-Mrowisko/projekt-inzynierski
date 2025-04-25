import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/auth/models/market_model.dart';
import '../auth/auth_repo.dart';
import '../exceptions.dart';

class MarketRepo extends GetxController {
  static MarketRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveMarket(MarketModel market) async {
    try {
      // we save our user model in the Users collection in json format
      await _db.collection("Markets").doc(market.id).set(market.toMap());
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

  // Future<MarketModel> fetchCurrentMarketDetails() async {
  //   try {
  //     // pull the document with X user from firebase
  //     final doc = await _db.collection("Markets").doc(AuthRepo.instance.authUser?).get();
  //
  //     if (doc.exists) {
  //       return UserModel.fromMap(doc);
  //     } else {
  //       return UserModel.empty();
  //     }
  //   } on FirebaseException catch (e) {
  //     throw MyFirebaseException(e.code).message;
  //   } on FormatException catch (_) {
  //     throw const MyFormatException();
  //   } on PlatformException catch (e) {
  //     throw MyPlatformException(e.code).message;
  //   } catch (e) {
  //     throw 'Coś poszło nie tak :(';
  //   }
  // }
}