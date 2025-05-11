import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../features/auth/screens/verify_email.dart';
import '../../../features/tags/controllers/tags_controller.dart';
import '../../../features/employees/controllers/user_controller.dart';
import '../../../features/schedules/screens/before_login/home_page.dart';
import '../../../features/schedules/screens/after_login/main_calendar.dart';
import '../exceptions.dart';

class AuthRepo extends GetxController {
  static AuthRepo get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance; //get the instance initialized from main

  /// get auth user data
  User? get authUser => _auth.currentUser;


  @override
  void onReady() {
    screenRedirect();
  }

  // handles which screen to show to the user - if hes authenticated, then .....
  screenRedirect() async {
    final user =  _auth.currentUser;


    if (user != null) {
      if (user.emailVerified){
        try {
          // Initialize controllers sequentially
          await _initializeControllers();
          _navigateToMainApp();
        } catch (e) {
          throw(e.toString());
        }
      } else {
        Get.offAll(() => const VerifyEmailScreen());
      }

    } else {
      // i guess we remain on the the welcome page
    }
  }


  Future<void> _initializeControllers() async {
    try {
      final userController = Get.find<UserController>();
      await userController.initialize();


      // Verify marketId after user data loads
      final marketId = userController.employee.value.marketId;


      if (marketId.isEmpty) {
        throw "MarketID not available after user load";
      }

      final tagsController = Get.find<TagsController>();
      await tagsController.initialize();

    } catch (e) {
      throw(e.toString());
    }
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

  Future<UserCredential> loginWithEmailAndPassword(String mail, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: mail, password: password);
    }on FirebaseAuthException catch (e) {
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

  /// LOGOUT
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // logout and show the home page
      Get.offAll(() => HomePage());
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


  /// RESET PSWD
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseException(e.code).message;
    }on FirebaseException catch (e) {
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