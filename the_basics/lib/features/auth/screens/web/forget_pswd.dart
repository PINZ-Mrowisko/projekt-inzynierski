import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/controllers/forget_pswd_controller.dart';
import 'package:the_basics/utils/validators/validation.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForgetPswd extends StatelessWidget {
  const ForgetPswd({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ForgetPswdController(),
    ); //create the instance here

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
              boxShadow: [
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
                const Text("Zapomniałeś hasła?"),
                const SizedBox(height: 20),
                const Text(
                  "Podaj swój adres email, a wyślemy Ci link do zresetowania hasła.",
                ),
                const SizedBox(height: 20),

                /// email form
                Form(
                  key: controller.forgetPswdFormKey,
                  child: TextFormField(
                    controller: controller.email,
                    validator: (value) => MyValidator.validateEmail(value),
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: CustomButton(
                    onPressed: () => controller.sendPswdResetEmail(),
                    text: 'Zresetuj hasło',
                    
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



