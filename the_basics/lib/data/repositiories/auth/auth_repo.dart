import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../features/auth/screens/verify_email.dart';
import '../../../features/schedules/controllers/tags_controller.dart';
import '../../../features/schedules/controllers/user_controller.dart';
import '../../../features/schedules/screens/before_login/home_page.dart';
import '../../../features/schedules/screens/after_login/main_calendar.dart';
import '../exceptions.dart';

class AuthRepo extends GetxController {
  static AuthRepo get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance; //get the instance initialized from mian

  /// get auth user data
  User? get authUser => _auth.currentUser;


  // this func gets called first after storage is initialized
  @override
  void onReady() {
    screenRedirect();
  }

  // handles which screen to show to the user - if hes authenticated, then .....
  screenRedirect() async {
    final user =  _auth.currentUser;
    if (user != null) {
      if (user.emailVerified){
        // Initialize controllers sequentially
        await _initializeControllers();
        _navigateToMainApp();
      } else {
        Get.offAll(() => const VerifyEmailScreen());
      }
      // LATER : ADD CHECK WHETHER KIEROWNIK OR NOT
    } else {
      // i guess we remain on the the welcome page
    }
  }

  Future<void> _initializeControllers() async {

    final userController = await Get.putAsync<UserController>(() async {
      final controller = UserController();
      //await controller.fetchCurrentUserRecord(); // Wait for user data
      return controller;
    });

    final marketId = Get.find<UserController>().employee.value.marketId;
    if (marketId.isEmpty) {
      throw "MarketID not available after user load";
    }

    Get.put(TagsController());
  }

  void _navigateToMainApp() {
    Future.delayed(Duration.zero, () { // Ensures context is available
      Get.offAll(() => const MainCalendar());
    });
  }

  /// email + password : REGISTER
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    //we use the build in methods from firebase, we dont store the pswd inside the DB
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseException(e.code).message;
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

  /// email verification
  Future<void> sendEmailVerification() async {
    try {
      // the current authenticated user that just registered will by recalled by the firebase instance
      return _auth.currentUser?.sendEmailVerification();
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

  Future<UserCredential> loginWithEmailAndPassword(String mail, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: mail, password: password);
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

  /// LOGOUT
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // logout and show the home page
      Get.offAll(() => HomePage());
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