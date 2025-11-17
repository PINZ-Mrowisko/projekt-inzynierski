import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/controllers/forget_pswd_controller.dart';
import 'package:the_basics/features/auth/screens/mobile/login_page_mobile.dart';
import 'package:the_basics/features/auth/screens/web/login_page.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/platform_wrapper.dart';

class ResetPswdMobile extends StatelessWidget {
  const ResetPswdMobile({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
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
                const SizedBox(height: 20),
                // logo
                Center(
                  child: SvgPicture.asset(
                    Get.isDarkMode 
                      ? 'assets/mrowisko_logo_blue_dark_mode.svg'
                      : 'assets/mrowisko_logo_blue.svg',
                    height: 48,
                  ),
                ),
                const SizedBox(height: 40),

                const Text("Email został wysłany!"),
                const SizedBox(height: 20),

                const Text("Na Twój adres email został wysłany link."),

                const Text("Kliknij go, aby ustawić nowe hasło."),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        child: CustomButton(
                          onPressed: () => Get.offAll(() => const PlatformWrapper(mobile: LoginPageMobile(), web: LoginPage())),
                          text: "Wróć do logowania",
                          width: 170,
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        child: CustomButton(
                          onPressed:
                              () => ForgetPswdController.instance
                                  .resendPswdResetEmail(email),
                          text: "Wyślij wiadomość ponownie",
                          width: 220,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
    });
  }
}
