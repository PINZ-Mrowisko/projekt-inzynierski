import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/models/user_model.dart';

import '../../../features/auth/models/market_model.dart';
import '../exceptions.dart';

class MarketRepo extends GetxController {
  static MarketRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveMarket(MarketModel market, UserModel user, String id) async {
    try {
      /// we save our market to the Markets collection
      await _db
          .collection("Markets")
          .doc(market.id)
          .set(market.toMap());

      /// and then save the first user inside the market's `members/` subcollection
      await FirebaseFirestore.instance
          .collection('Markets')
          .doc(market.id)
          .collection('members')
          .doc(id)
          .set(user.toMap());

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