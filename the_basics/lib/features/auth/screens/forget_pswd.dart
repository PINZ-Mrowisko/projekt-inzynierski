import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/controllers/forget_pswd_controller.dart';
import 'package:the_basics/utils/validators/validation.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';

class ForgetPswd extends StatelessWidget {
  const ForgetPswd({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ForgetPswdController(),
    ); //create the instance here

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Zapomniałeś hasła?"),
                const SizedBox(height: 20),
                const Text("Wpisz adres email to ci zresetujemy"),
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

                CustomButton(
                  onPressed: () => controller.sendPswdResetEmail(),
                  text: 'Wyślij maila',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
