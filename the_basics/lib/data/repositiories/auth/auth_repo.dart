import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/auth/screens/verify_email.dart';
import '../../../features/tags/controllers/tags_controller.dart';
import '../../../features/employees/controllers/user_controller.dart';
import '../../../features/schedules/screens/before_login/home_page.dart';
import '../../../features/schedules/screens/after_login/main_calendar.dart';
import '../exceptions.dart';

class AuthRepo extends GetxController {
  static AuthRepo get instance => Get.find();

  final _auth = FirebaseAuth.instance; //get the instance initialized from main

  /// get a sharedPreferences instane - we use it to store user tokens after login
  final SharedPreferences _prefs;

  // try this - if doesnt work change later
  AuthRepo(this._prefs);

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

  Future<UserCredential> loginWithEmailAndPassword(String mail, String password, bool rememberMe) async {
    try {


      await FirebaseAuth.instance.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );

      final userCredential = await _auth.signInWithEmailAndPassword(email: mail, password: password);

      //print('Remember me enabled: $rememberMe');
      if(rememberMe) {
        await _prefs.setBool("remember_me", true);

        //final token = await userCredential.user!.getIdToken();
        //print('Obtained token: ${token != null ? "[exists]" : "null"}');
        // if(token != null){
        //   await _persistToken(token);
        // }
      }

      return userCredential;
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
      /// remove saved prefs if user chooses a manual log out
      await _prefs.remove('remember_me');
      await _prefs.remove('auth_token');

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

  /// HANDLE REMEMBER ME FEATURE

  /// TOKEN MANAGEMENT

  // Future<void> _persistToken(String token) async {
  //   await _prefs.setString('auth_token', token);
  // }
  //
  // Future<String?> _getStoredToken() async {
  //   return await _prefs.getString('auth_token');
  // }

  static Future<User?> getFirebaseUser() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    firebaseUser ??= await FirebaseAuth.instance.authStateChanges().first;
    return firebaseUser;
  }


  Future<bool> tryAutoLogin() async {
    try {
      // check if "remember me" was enabled
      final rememberMe = _prefs.getBool('remember_me') ?? false;
      //print('Remember me status: $rememberMe');

      if (!rememberMe) {
        //print('Remember me disabled - skipping auto-login');
        return false;
      }

      final currUser = getFirebaseUser();

      // check Firebases native token (auto-refreshed by SDK)
      // if (currUser != null) {
      //   //print('User already authenticated');
      //   return true;
      // }

      //final token = await _getStoredToken();
      //print('Retrieved token: ${token != null ? "[exists]" : "null"}');

      // if (token != null) {
      //   await _auth.signInWithCustomToken(token);
      //   return _auth.currentUser != null;
      // }


      return false;
    } catch (e) {
      await logout();
      return false;
    }
  }
}