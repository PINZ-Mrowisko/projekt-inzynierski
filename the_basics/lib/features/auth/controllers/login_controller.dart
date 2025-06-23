import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';


class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// Variables
  final email = TextEditingController();
  final pswd = TextEditingController();

  final hidePswd = true.obs;
  final rememberMe = false.obs;
  final errorMessage = ''.obs;

  final localStorage = GetStorage();

  // allows us to access data from the form
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  void clearControllers() {
    email.clear();
    pswd.clear();
    hidePswd.value = true;
    errorMessage.value = '';
  }

  Future<void> emailAndPasswordSignIn() async {
    try {
      errorMessage.value = '';

      // start Loading
      if (!loginFormKey.currentState!.validate()) {
        return;
      }

      // login user using Email & Password auth
      final userCredentials = await AuthRepo.instance
          .loginWithEmailAndPassword(
        email.text.trim(),
        pswd.text.trim(),
        rememberMe.value
      );
      //print("success login");

      email.clear();
      pswd.clear();
      hidePswd.value = true;
      rememberMe.value = false;

      // redirect using our fancy func
      AuthRepo.instance.afterLogin();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getFriendlyErrorMessage(e);
    } on FirebaseException catch (e) {
      errorMessage.value = 'Błąd Firebase: ${e.message}';
    } on FormatException catch (e) {
      errorMessage.value = 'Nieprawidłowy format danych.';
    } on PlatformException catch (e) {
      errorMessage.value = 'Błąd systemowy: ${e.message}';
    } catch (e) {
      errorMessage.value = 'Coś poszło nie tak :(';
    }
  }
  String _getFriendlyErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Nieprawidłowy email lub hasło.';
        case 'too-many-requests':
          return 'Zbyt wiele prób logowania. Spróbuj później.';
        case 'network-request-failed':
          return 'Błąd połączenia. Sprawdź internet.';
        default:
          return 'Wystąpił błąd podczas logowania: ${error.message}';
      }
    }
    return 'Wystąpił nieznany błąd. Spróbuj ponownie.';
  }

}
