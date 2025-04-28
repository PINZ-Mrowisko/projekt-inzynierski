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

  Future<void> addNewEmployee(UserModel employee) async {
    try {
      await _db.collection('Users').add({
        'firstName': employee.firstName,
        'lastName': employee.lastName,
        'email': employee.email,
        'marketId': employee.marketId,
        'phoneNumber': employee.phoneNumber,
        'contractType': employee.contractType,
        'maxWeeklyHours': employee.maxWeeklyHours,
        'shiftPreference': employee.shiftPreference,
        'tags': employee.tags,
        'isDeleted': false,
        'insertedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw 'Firebase error: ${e.message}';
    } catch (e) {
      throw 'Failed to add employee: ${e.toString()}';
    }
  }

  /// Fetches user detailes based on current users ID
  Future<UserModel> fetchCurrentUserDetails() async {
    try {
      // pull the document with X user from firebase
      final doc = await _db.collection("Users").doc(AuthRepo.instance.authUser?.uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc);
      } else {
        return UserModel.empty();
      }
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
      final snapshot = await _db.collection('Users')
          .where('marketId', isEqualTo: marketId)
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
  Future<void> updateCurrentUserDetails(UserModel updatedUser) async {
    try {
      await _db.collection("Users").doc(updatedUser.id).update(updatedUser.toMap());
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

  /// Updates the whole user based on users current id
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

  /// remove the account of the current authenticated user
  Future<void> removeCurrentUser(String userId) async {
    try {
      await _db.collection("Users").doc(userId).delete();
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