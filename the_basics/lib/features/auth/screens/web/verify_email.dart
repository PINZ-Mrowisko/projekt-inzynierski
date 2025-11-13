import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/common_widgets/navbar.dart';
import '../../controllers/verify_email_controller.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/validators/validation.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final verifyController = Get.put(VerifyEmailController());

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SvgPicture.asset(
                    Get.isDarkMode 
                      ? 'assets/mrowisko_logo_blue_dark_mode.svg'
                      : 'assets/mrowisko_logo_blue.svg',
                      height: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Proszę potwierdź swój adres email.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Na twój adres email została wysłana wiadomość z linkiem.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                SizedBox(
                  width: 140,
                  child: CustomButton(
                    onPressed: () {
                      verifyController.sendEmailVerification(context);
                    },
                    text: 'Wyślij ponownie',
                  ),
                ),

                    const SizedBox(width: 20),
                SizedBox(
                  width: 140,
                  child: CustomButton(
                    onPressed: () {
                      verifyController.checkEmailVerificationStatus(context);
                    },
                    text: 'Kontynuuj',
                  ),
                ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




