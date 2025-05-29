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

  void clearControllers() {
    email.clear();
    pswd.clear();
    hidePswd.value = true;
  }

  Future<void> emailAndPasswordSignIn() async {
    try {
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
      print("success login");

      email.clear();
      pswd.clear();

      // redirect using our fancy func
      AuthRepo.instance.afterLogin();
    } catch (e) {
      //print("display error msg here....");
    }
  }
}
