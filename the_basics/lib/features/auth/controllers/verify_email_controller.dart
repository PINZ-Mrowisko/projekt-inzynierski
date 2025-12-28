import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:flutter/material.dart';

import '../../employees/controllers/user_controller.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

sendEmailVerification([BuildContext? context]) async {
  try {
    await AuthRepo.instance.sendEmailVerification();

    if (context != null) {
      showCustomSnackbar(
        context,
        "Link weryfikacyjny został wysłany ponownie.",
      );
    }
  } catch (e) {
    if (context != null) {
      showCustomSnackbar(
        context,
        "Nie udało się wysłać wiadomości. Spróbuj ponownie później.",
      );
    }
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

  checkEmailVerificationStatus(BuildContext context) async {
    await FirebaseAuth.instance.currentUser?.reload();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && currentUser.emailVerified) {
      final userController = Get.find<UserController>();

      if (userController.isAdmin.value) {
        Get.offAllNamed('/grafik-ogolny-kierownik');
      } else {
        Get.offAllNamed('/grafik-ogolny-pracownicy');
      }
    } else {
      showCustomSnackbar(
        context,
        "Sprawdź swoją skrzynkę pocztową i kliknij w link weryfikacyjny.",
      );
    }
  }

}

