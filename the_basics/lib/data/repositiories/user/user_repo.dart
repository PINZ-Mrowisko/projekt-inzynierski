import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';

import '../../../features/auth/models/user_model.dart';
import '../exceptions.dart';

class UserRepo extends GetxController {
  static UserRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    try {
      // we save our user model in the Users collection in json format
      await _db.collection("Users").doc(user.id).set(user.toMap());
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

  Future<void> addNewEmployee(UserModel employee, UserModel newUserTemp) async {
    try {
      //await _db.collection('Users').doc(employee.id).set(employee.toMap());
      await _db.collection('Users').doc(employee.id).set(newUserTemp.toMap());

      // also append the new user to the members subcollection
      await _db
          .collection('Markets')
          .doc(employee.marketId)
          .collection('members')
          .doc(employee.id)
          .set(employee.toMap());

    } on FirebaseException catch (e) {
      throw 'Firebase error: ${e.message}';
    } catch (e) {
      throw 'Failed to add employee: ${e.toString()}';
    }
  }

  /// Fetches user detailes based on current users ID
  Future<UserModel> fetchCurrentUserDetails() async {
    try {
      final uid = AuthRepo.instance.authUser?.uid;

      if (uid == null) throw 'Brak zalogowanego użytkownika';

      // pull the document with X user from firebase
      final userDoc = await _db.collection("Users").doc(AuthRepo.instance.authUser?.uid).get();

      if (!userDoc.exists) {
        return UserModel.empty();
      }

      final marketId = userDoc.data()?['marketId'];
      if (marketId == null) throw 'Brak marketId dla użytkownika';

      // fetch full user data from market/members
      final fullUserDoc = await _db
          .collection("Markets")
          .doc(marketId)
          .collection("members")
          .doc(uid)
          .get();

      if (!fullUserDoc.exists) {
        return UserModel.empty();
      }

      return UserModel.fromMap(fullUserDoc);


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

  /// get all available employees specific to the market
  Future<List<UserModel>> getAllEmployees(String marketId) async {
    try{
      // final snapshot = await _db.collection('Users')
      //     .where('marketId', isEqualTo: marketId)
      //     .where('isDeleted', isEqualTo: false)
      //     .get();

      final snapshot = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('members')
          .where('isDeleted', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No emps found for marketId: $marketId');
        return [];
      }

      // go through each of the user docs and format them using our method
      final list = snapshot.docs.map((e) => UserModel.fromMap(e)).toList();
      return list;
    }on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    }catch (e) {
      print("Error fetching employees: $e");
      throw 'Coś poszło nie tak przy pobieraniu pracowników :(';
    }
  }

  /// Updates the whole user based on user id
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      //await _db.collection("Users").doc(updatedUser.id).update(updatedUser.toMap());

      await _db
          .collection("Markets")
          .doc(updatedUser.marketId)
          .collection("members")
          .doc(updatedUser.id)
          .update(updatedUser.toMap());

    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      print("Error of update: $e");
      throw 'Coś poszło nie tak przy aktualizowaniu pracownika :(';
    }
  }

  /// Updates the whole user based on users current id - NOT USED
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db.collection("Users").doc(AuthRepo.instance.authUser?.uid).update(json);
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

  /// mark the provided user as deleted
  Future<void> removeUser(String userId, String marketId) async {
    try {
      await _db.collection("Users").doc(userId).update({
      'isDeleted': true,
      'updatedAt': Timestamp.now()});

      await _db
          .collection("Markets")
          .doc(marketId)
          .collection("members")
          .doc(userId)
          .update({
        'isDeleted': true,
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Coś poszło nie tak przy usuwaniu pracownika :(';
    }
  }

  Future<UserModel> getUserDetails(String userId, String marketId) async {
    final doc = await _db.collection("Markets")
        .doc(marketId)
        .collection("members")
        .doc(userId).get();

    if (doc.exists) {
      return UserModel.fromMap(doc);
    }
    throw 'Nie mam go';
  }
}