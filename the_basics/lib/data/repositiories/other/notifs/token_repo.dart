import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../features/notifs/models/token_model.dart';
import '../../exceptions.dart';

class TokenRepo extends GetxController {
  static TokenRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// save or update FCM token for a user
  /// Token is saved in Users/{userId}/FCMTokens/{token} subcollection
  Future<void> saveToken(TokenModel token, String marketId) async {
    try {
      print("here saving - in repo");
      await _db
          .collection('Markets')
          .doc(marketId)
          .collection('members')
          .doc(token.userId)
          .collection('FCMTokens')
          .doc(token.token) // we use token as document ID for uniqueness
          .set(token.toMap());
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (_) {
      throw 'Coś poszło nie tak przy zapisie tokenu FCM';
    }
  }

  /// get all active tokens for a specific user
  Future<List<TokenModel>> getUserTokens(String userId, String marketId) async {
    try {
      final snapshot = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('members')
          .doc(userId)
          .collection('FCMTokens')
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map((doc) => TokenModel.fromSnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (_) {
      throw 'Coś poszło nie tak przy pobieraniu tokenów użytkownika';
    }
  }

  /// update token activity status and lastActive timestamp
  Future<void> updateTokenActivity(String userId, String token, bool isActive, String marketId) async {
    try {
      await _db
          .collection('Markets')
          .doc(marketId)
          .collection('members')
          .doc(userId)
          .collection('FCMTokens')
          .doc(token)
          .update({
        'isActive': isActive,
        'lastActive': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się zaktualizować tokenu: ${e.toString()}';
    }
  }

  /// mark token as inactive (for now we will use it when user logs out or token becomes invalid)
  Future<void> deactivateToken(String userId, String token, String marketId) async {
    try {
      await _db
          .collection('Markets')
          .doc(marketId)
          .collection('members')
          .doc(userId)
          .collection('FCMTokens')
          .doc(token)
          .update({
        'isActive': false,
        'lastActive': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się dezaktywować tokenu: ${e.toString()}';
    }
  }

  /// delete a specific token (hard delete)
  Future<void> deleteToken(String userId, String token, String marketId) async {
    try {
      await _db
          .collection('Markets')
          .doc(marketId)
          .collection('members')
          .doc(userId)
          .collection('FCMTokens')
          .doc(token)
          .delete();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się usunąć tokenu: ${e.toString()}';
    }
  }


  /// clean up inactive tokens older than specified days
  Future<void> cleanupInactiveTokens(int daysOld) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      final usersSnapshot = await _db.collection('members').get();

      for (final userDoc in usersSnapshot.docs) {
        final tokensSnapshot = await userDoc.reference
            .collection('FCMTokens')
            .where('lastActive', isLessThan: cutoffDate.toIso8601String())
            .where('isActive', isEqualTo: false)
            .get();

        final batch = _db.batch();
        for (final tokenDoc in tokensSnapshot.docs) {
          batch.delete(tokenDoc.reference);
        }
        if (tokensSnapshot.docs.isNotEmpty) {
          await batch.commit();
        }
      }
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się wyczyścić starych tokenów: ${e.toString()}';
    }
  }

  /// check if a specific token exists and is active
  Future<bool> isTokenActive(String userId, String token, String marketId) async {
    try {
      final doc = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('members')
          .doc(userId)
          .collection('FCMTokens')
          .doc(token)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['isActive'] == true;
      }
      return false;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się sprawdzić statusu tokenu: ${e.toString()}';
    }
  }
}