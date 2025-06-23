import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';

import '../../../features/auth/screens/login_page.dart';
import '../../../features/auth/screens/verify_email.dart';
import '../../../features/tags/controllers/tags_controller.dart';
import '../../../features/employees/controllers/user_controller.dart';
import '../../../features/schedules/screens/after_login/main_calendar.dart';
import '../exceptions.dart';

class AuthRepo extends GetxController {
  static AuthRepo get instance => Get.find();

  final _auth = FirebaseAuth.instance; //get the instance initialized from main

  /// get a sharedPreferences instane - we use it to store user tokens after login
  final SharedPreferences _prefs;
  final GetStorage _box = GetStorage();
  static const String _lastRouteKey = 'last_route';

  // try this - if doesnt work change later
  AuthRepo(this._prefs);

  /// get auth user data
  User? get authUser => _auth.currentUser;


  @override
  Future<void> onReady() async {
    final user =  _auth.currentUser;
    if (user == null) {
      //print("in not authenitaced");
    } else {
      //print("detected a user");
    }
    await _initializeControllers();
  }

  // handles which screen to show to the user - if hes authenticated, then .....
  screenRedirect() async {
    final user =  _auth.currentUser;
    //print("moved here");
    //print(user?.uid);

    if (user != null) {
      if (user.emailVerified){
        try {
          // Initialize controllers sequentially
          await _initializeControllers();
          //_navigateToMainApp();
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

  // handles after login functions for emps and manager
  afterLogin() async {
    final user =  _auth.currentUser;
    //print("moved here");
    //print(user?.uid);

    if (user != null) {
        try {
          // Initialize controllers sequentially
          await _initializeControllers();

          /// perform a check if its the first login, if yes mark the flag
          final userController = Get.find<UserController>();
          final employee = userController.employee.value;

          if (employee.hasLoggedIn == false) {
            await userController.updateEmployee(employee.copyWith(hasLoggedIn: true));
            //print("Updated hasLoggedIn to true for first login.");
          }

          _navigateToMainApp();
        } catch (e) {
          throw(e.toString());
        }


    } else {
    //print("user is null");
    }
  }

  void saveLastRoute(String route) {
    _box.write(_lastRouteKey, route);
    //print('Saved last route: $route');
  }

  String? getLastRoute() {
    final route = _box.read<String>(_lastRouteKey);
    //print('Retrieved last route: $route');
    return route;
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


      final leaveController = Get.find<LeaveController>();
      await leaveController.initialize();

    } catch (e) {
      throw(e.toString());
    }
  }

  void _navigateToMainApp() {
    Future.delayed(Duration.zero, () { // Ensures context is available
      //Get.offAll(() => const MainCalendar());
      Get.offAllNamed('/grafik-ogolny');
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

      if(rememberMe) {
        await _prefs.setBool("remember_me", true);
      }

      return userCredential;
    }on FirebaseAuthException catch (e) {
      rethrow;
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


      //removes the saved user so it doesnt log us back after logout
      await FirebaseAuth.instance.setPersistence(Persistence.NONE);
      await FirebaseAuth.instance.signOut();

      Get.deleteAll(force: true);

      await Future.delayed(Duration(milliseconds: 1000));

      // logout and show the login page
      Get.offAll(() => LoginPage());
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

      return false;
    } catch (e) {
      await logout();
      return false;
    }
  }
}