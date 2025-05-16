import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/features/auth/screens/reset_pswd.dart';

class ForgetPswdController extends GetxController {
  static ForgetPswdController get instance => Get.find();

  final email = TextEditingController();
  GlobalKey<FormState> forgetPswdFormKey = GlobalKey<FormState>();

  /// send reset pswd email
  sendPswdResetEmail() async {
    try {
      // add the is loading check

      if(!forgetPswdFormKey.currentState!.validate()){
        return;
      }
      // in the curr aproach we ask the user to input their mail, maybe we can just pick it form login screen
      await AuthRepo.instance.resetPassword(email.text.trim());

      // show success msg to notify that email has been sent
      // snack bar !

      // redirect to reset pswd screen
      Get.to(() => ResetPswd(email: email.text.trim()));
    } catch (e) {
      // stop the loader loading
      // display warning snackbar
      //Get.snackbar(titleText: "Niepowodzenie", messageText: e.toString());
      print(e.toString());
    }
  }

  resendPswdResetEmail(String email) async {
    try {
      // start loader
      await AuthRepo.instance.resetPassword(email);

      //display success msg

    } catch (e) {
      print(e.toString());
    }
  }
}