import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/screens/home_page.dart';

import '../../../data/repositiories/auth/auth_repo.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  sendEmailVerification() async{
    try {
      await AuthRepo.instance.sendEmailVerification();
    } catch (e) {
      // print the exception msg in a snackbar or smth
    }
  }

  setTimerForAutoRedirect() {
    Timer.periodic(
      const Duration(seconds: 1),
        (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        final user  = FirebaseAuth.instance.currentUser;
        if(user?.emailVerified ?? false) {
          // if user is verified stop the timer and go to homepage
          timer.cancel();
          // go redirect the user to the landing schedule page (widok ogolny /  dashboard kierownika)
          AuthRepo.instance.screenRedirect();
        }
        }
    );
  }

  // manually check if email verified
  checkEmailVerificationStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.emailVerified)
      {
        Get.off(() => HomePage());
      }
  }
}