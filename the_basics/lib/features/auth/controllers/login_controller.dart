import 'package:flutter/cupertino.dart';
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

  final localStorage = GetStorage();

  // allows us to access data from the form
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  Future<void> emailAndPasswordSignIn() async {
    try {
      // start Loading
      if (!loginFormKey.currentState!.validate()) {
        return;
      }

      // save data locally if Remember Me is selected
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', pswd.text.trim());
      }

      // login user using Email & Password auth
      final userCredentials = await AuthRepo.instance
          .loginWithEmailAndPassword(
        email.text.trim(),
        pswd.text.trim(),
      );

      /// TO DO:
      /// implement a remember me feature to shorten login


      // redirect using our fancy func
      AuthRepo.instance.screenRedirect();
    } catch (e) {
      //print("display error msg here....");
    }
  }
}
