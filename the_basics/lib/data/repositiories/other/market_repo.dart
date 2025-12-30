import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/models/user_model.dart';

import '../../../features/auth/models/market_model.dart';
import '../exceptions.dart';

class MarketRepo extends GetxController {
  static MarketRepo get instance => Get.find();

  final FirebaseFirestore _db;

  // Konstruktor z możliwością podania mocka
  MarketRepo({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  Future<void> saveMarket(MarketModel market, UserModel user, String id) async {
    try {
      // Zapis rynku
      await _db.collection("Markets").doc(market.id).set(market.toMap());

      // Zapis pierwszego użytkownika w subkolekcji
      await _db
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
}
